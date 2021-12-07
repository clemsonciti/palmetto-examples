import torch
import torch.nn as nn
import torchvision
import torch.multiprocessing as mp
import torch.distributed as dist
from argparse import ArgumentParser
import os

from train_ddp import train



if __name__ == "__main__":

    parser = ArgumentParser()
    parser.add_argument('--nodes', default=1, type=int)
    parser.add_argument('--local_ranks', default=0, type=int,help="Node's order number in [0, num_of_nodes-1]")
    parser.add_argument('--ip_address', type=str, required=True,help='ip address of the host node')
    parser.add_argument("--checkpoint", default=None,help="path to checkpoint to restore")
    parser.add_argument('--ngpus', default=1, type=int,help='number of gpus per node')
    parser.add_argument('--epochs', default=2, type=int, metavar='N',help='number of total epochs to run')
    parser.add_argument('--data_path', default=".", type=str, required=True, help='path to data directory')

    args = parser.parse_args()
    # Total number of gpus availabe to us.
    args.world_size = args.ngpu * args.nodes
    # add the ip address to the environment variable so it can be easily avialbale
    os.environ['MASTER_ADDR'] = args.ip_adress
    print("ip_adress is", args.ip_adress)
    os.environ['MASTER_PORT'] = '8888'
    os.environ['WORLD_SIZE'] = str(args.world_size)
    # nprocs: number of process which is equal to args.ngpu here
    mp.spawn(train, nprocs=args.ngpus, args=(args,))
