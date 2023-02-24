# pytorch
import torch
import torch.nn as nn
import torch.optim as optim
import torch.distributed as dist
from torch.utils.data import DataLoader
from torch.utils.data.distributed import DistributedSampler
from torch.nn.parallel import DistributedDataParallel as DDP

# torchvision
from torchvision import models
from torchvision import datasets
from torchvision import transforms

# torchmetrics
from torchmetrics import Accuracy

# python
import os
import argparse
from typing import Callable, TypedDict


class Trainer:
    """class that trains the model"""

    def __init__(self,
                 model: nn.Module,
                 train_loader: DataLoader,
                 optimizer: optim.Optimizer,
                 criterion: nn.Module,
                 *,
                 test_loader: DataLoader = None,
                 metric: Callable[[torch.Tensor, torch.Tensor], torch.Tensor] = None,
                 snapshot_path: str = None):
        self.local_rank = int(os.environ['LOCAL_RANK'])
        self.global_rank = int(os.environ['RANK'])
        self.train_loader = train_loader
        self.optimizer = optimizer
        self.criterion = criterion
        self.test_loader = test_loader
        self.metric = metric
        self.model = model.to(self.local_rank)

        self.current_epoch = 0
        self.snapshot_path = snapshot_path if snapshot_path else 'snapshot.pth'
        if os.path.exists(self.snapshot_path):
            print(f'GPU {self.global_rank} | loading snapshot')
            self._load(self.snapshot_path)
        self.model = DDP(model, device_ids=[self.local_rank])

    class Snapshot(TypedDict):
        model: dict
        epoch: int

    def _train(self):
        """trains model for one epoch"""
        self.model.train()
        total_loss = 0
        for features, labels in self.train_loader:
            # Move to device
            features: torch.Tensor = features.to(self.local_rank)
            labels: torch.Tensor = labels.to(self.local_rank)

            self.optimizer.zero_grad()

            # Forward pass
            outputs: torch.Tensor = self.model(features)
            outputs = torch.softmax(outputs, -1)

            # Calculate loss
            loss: torch.Tensor = self.criterion(outputs, labels)
            loss.backward()

            # Update weights and biases
            self.optimizer.step()

            total_loss += loss.item()
        return total_loss / len(self.train_loader)

    def _evaluate(self):
        """evaluates model for one epoch"""
        self.model.eval()
        loss, accuracy = 0, 0
        with torch.inference_mode():
            for i, (features, labels) in enumerate(self.test_loader):
                # Move data to device
                features = features.to(self.local_rank)
                labels = labels.to(self.local_rank)

                # Forward pass
                outputs: torch.Tensor = self.model(features)
                predictions: torch.Tensor = torch.softmax(outputs, dim=-1).argmax(dim=-1)

                # Calculate loss
                loss += self.criterion(outputs, labels).item()
                accuracy += float(self.metric(predictions, labels))
        return loss / len(self.test_loader), accuracy / len(self.test_loader)

    def _load(self, path):
        snapshot: Trainer.Snapshot = torch.load(path, map_location='cpu')

        self.model.load_state_dict(snapshot['model'])
        self.current_epoch = snapshot['epoch']

    def _save(self):
        snapshot: Trainer.Snapshot = {
            'model': self.model.module.state_dict(),
            'epoch': self.current_epoch
        }

        torch.save(snapshot, self.snapshot_path)

    def fit(self, epochs: int):
        current_epoch = self.current_epoch
        for epoch in range(current_epoch, self.current_epoch + epochs):
            # training
            train_loss = self._train()
            # evaluating
            test_loss, accuracy = None, None
            if self.test_loader and self.metric:
                test_loss, accuracy = self._evaluate()

            self.current_epoch += 1

            # logging
            print(f'GPU {self.global_rank} | ' +
                  f'Epoch {self.current_epoch} | ' +
                  f'train loss {train_loss: .2f}' +
                  (f' | test loss {test_loss: .2f} | '
                   f'accuracy {accuracy: .2f}' if test_loss or accuracy else '')
                  )
            # saving model
            if self.global_rank == 0:
                print(f'GPU {self.global_rank} | saving model')
                self._save()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--epochs', type=int)
    parser.add_argument('-p', '--pth', type=str)
    args = parser.parse_args()

    # initialize the process group
    dist.init_process_group("nccl")
    local_rank = int(os.environ['LOCAL_RANK'])

    # Hyper parameters
    batch_size = 32
    lr = 1e-3

    train_transform = transforms.Compose([
        transforms.RandomCrop(32, padding=4),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
    ])

    test_transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
    ])

    train_data = datasets.CIFAR10(
        root='data',
        train=True,
        transform=train_transform,
        download=True,
    )

    test_data = datasets.CIFAR10(
        root='data',
        transform=test_transform,
        download=True,
    )
    ncpus = max(int(os.getenv('NCPUS', 1))-1, 1)
    train_loader = DataLoader(
        dataset=train_data,
        batch_size=batch_size,
        sampler=DistributedSampler(train_data),
        num_workers=ncpus
    )

    test_loader = DataLoader(
        dataset=test_data,
        batch_size=batch_size,
        sampler=DistributedSampler(test_data),
        num_workers=ncpus
    )

    model = models.resnet18()
    model.fc = nn.Linear(model.fc.in_features, len(train_data.classes))

    # Optimizer
    optimizer = optim.Adam(model.parameters(), lr=lr)

    # Criterion
    criterion = nn.CrossEntropyLoss()

    trainer = Trainer(
        model=model,
        train_loader=train_loader,
        optimizer=optimizer,
        criterion=criterion,
        test_loader=test_loader,
        metric=Accuracy(task='multiclass', num_classes=len(train_data.classes)).to(local_rank),
        snapshot_path=args.pth
    )

    trainer.fit(args.epochs if args.epochs else 1)
    dist.destroy_process_group()


if __name__ == '__main__':
    main()
