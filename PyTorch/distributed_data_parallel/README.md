# Intro to Pytorch with Distributed Data Parallel

## Purpose
The objective is to provide an introduction to PyTorch with distributed data parallelism on the Palmetto Cluster.
The code provided shows the process of training a model given a dataset using DDP on multiple GPUs over multiple nodes.
This file includes step-by-step instructions on how to set up the environment and Palmetto cluster for running the code. 
This file explains each step in detail and provides code snippets with explanations.

## Palmetto Clusters Setup
Select some hardware requirements and submit an interactive job.
```shell
qsub -I -l select=2:mem=16gb:ncpus=4:ngpus=2:gpu_model=v100,walltime=1:00:00
```
Load some modules.
```shell
module load anaconda3/2022.05-gcc/9.5.0 cuda/11.6.2-gcc/9.5.0 cudnn/8.1.0.77-11.2-gcc/9.5.0
```
Create a virtual environment.
```shell
conda create -n torchenv python=3.9
```
Activate environment.
```shell
source activate torchenv
```
Install packages.
```shell
conda install pytorch torchvision torchaudio pytorch-cuda=11.7 -c pytorch -c nvidia
conda install -c conda-forge torchmetrics
```

## Setup
First, we need to initialize the process group. There are three built-in backends to choose from.
It is recommended to use `gloo` for cpu and `nccl` for cuda.

```python
import torch.distributed as dist

dist.init_process_group("nccl")
```

## Dataset
Next, let's get a dataset. The CIFAR-10 dataset we'll be using includes 10 classes 
organized into various animals and vehicles. We'll also be need to convert the images to Tensors.


```python
from torchvision import datasets
from torchvision import transforms

transform = transforms.Compose([
    transforms.ToTensor()
])

train_data = datasets.CIFAR10(
    root='data',
    train=True,
    transform=transform,
    download=True,
)
```

## DataLoader
To load the data, we'll need `DataLoader` class. In addition to passing in the 
usual arguments, dataset and batch_size, we'll also want a sampler to distribute
our data over different processes.


```python
from torch.utils.data import DataLoader
from torch.utils.data.distributed import DistributedSampler

train_loader = DataLoader(
    dataset=train_data,
    batch_size=32,
    sampler=DistributedSampler(train_data)
)
```

## Model
Now we need a model. For simplicity, we'll be using the ResNet-18 convolutional neural network
consisting of 18 layers. The output layer will be modified to give us the correct amount of classes.


```python
from torch import nn
from torchvision import models

model = models.resnet18()
model.fc = nn.Linear(model.fc.in_features, len(train_data.classes))
```

## Loss Function and Optimizer
<p>
For classification problems, cross-entropy loss is commonly used to measure
the difference between the predicted probability distribution and the true distribution.
For simplicity, the Stochastic Gradient Descent will be used to update the parameters.
It simply subtracts the gradient of the loss with respect to the parameters and
multiplies it by the learning rate.
</p>

```python
from torch import nn
from torch import optim

criterion = nn.CrossEntropyLoss()
optimizer = optim.SGD(model.parameters(), lr=1e-3)
```

## Training

Next is the training step. This class will train the model. Notice that we
are grabbing the `local_rank` and `global_rank` from the environment variables.
The local rank determines what gpu the model will train on. The global
rank will help us distinguish which node the model is training on.
The model is also wrapped by the `DistributedDataParallel` class to implement
data parallelism to run the module across multiple machines.


```python
import os
import torch
from torch import nn
from torch import optim
from torch.utils.data import DataLoader
from torch.nn.parallel import DistributedDataParallel as DDP

class Trainer:
    """
    Class that trains the model
    """
    def __init__(self, model: nn.Module, train_loader: DataLoader, optimizer: optim.Optimizer, criterion: nn.Module):
        self.local_rank = int(os.environ['LOCAL_RANK'])
        self.global_rank = int(os.environ['RANK'])
        self.model = DDP(model.to(self.local_rank), device_ids=[self.local_rank])
        self.train_loader = train_loader
        self.optimizer = optimizer
        self.criterion = criterion

    def _run_epoch(self):
        """
        This method runs a single epoch.
        """
        for features, labels in self.train_loader:
            # Move tensors to corresponding gpu
            features: torch.Tensor = features.to(self.local_rank)
            labels: torch.Tensor = labels.to(self.local_rank)

            # Set accumulated gradients in optimizer to zero
            self.optimizer.zero_grad()

            # Forward pass
            outputs: torch.Tensor = self.model(features)
            
            # Squash the numbers into probabilities
            outputs = torch.softmax(outputs, -1)
            
            # Calculate the loss
            loss: torch.Tensor = self.criterion(outputs, labels)
            
            # Backward pass
            loss.backward()

            # update weights and biases
            self.optimizer.step()

    def fit(self, epochs: int):
        self.model.train()
        for epoch in range(epochs):
            print(f'GPU {self.global_rank} | Epoch {epoch}')
            self._run_epoch()
```
Make an instance of the trainer.
```python
trainer = Trainer(
    model=model,
    train_loader=train_loader,
    optimizer=optimizer,
    criterion=criterion,
)
```
Train the model.
```python
epochs = 1
trainer.fit(epochs)
```

## Cleanup
Finally, we clean up by destroying the process group.
```python
import torch.distributed as dist
dist.destroy_process_group()
```

## Execution
To actually run the code, we'll use `torchrun`. This command will set up the
environment variables for us by passing in some arguments.

### One node execution
```shell
torchrun \
  --nnodes=1 \
  --nproc_per_node=gpu \
  --rdzv_id=12345 \
  --rdzv_backend=c10d \
  --rdzv_endpoint=$HOSTNAME:3000 \
  main.py
```

### Multi node execution
Both nodes must run the `torchrun` command with the same arguments.
You can get to the other nodes with `ssh`.

```shell
torchrun \
  --nnodes=2 \
  --nproc_per_node=2 \
  --rdzv_id=12345 \
  --rdzv_backend=c10d \
  --rdzv_endpoint=<Parent Hostname>:3000 \
  main.py
```

You can find out the hostname with by printing it out.
```shell
echo $HOSTNAME
```

### Bash execution
To make it simpler, we can write a bash script that will run the same command on both nodes.
```shell
#!/bin/bash
source /etc/profile.d/modules.sh
module load anaconda3/2022.05-gcc/9.5.0 cuda/11.6.2-gcc/9.5.0 cudnn/8.1.0.77-11.2-gcc/9.5.0
source activate parallel
cd <your directory> || exit
torchrun --nnodes=2 --nproc_per_node=2 --rdzv_id=12345 --rdzv_backend=c10d --rdzv_endpoint="$1":3000  "$2"
echo "$HOSTNAME" finished tasks
```
To run we do:
```shell
pbsdsh -- bash script.sh $HOSTNAME main.py
```