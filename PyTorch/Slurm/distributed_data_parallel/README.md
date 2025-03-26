# Intro to Pytorch with Distributed Data Parallel

## Purpose
The objective is to provide an introduction to PyTorch with distributed data parallelism on the Palmetto Cluster.
The code provided shows the process of training a model given a dataset using DDP on multiple GPUs over multiple nodes.
This file includes step-by-step instructions on how to set up the environment and Palmetto cluster for running the code. 
This file explains each step in detail and provides code snippets with explanations.

## Palmetto Cluster Setup
Copy the contents of this project folder into a new directory on Palmetto. We will refer to the location of this directory as `<project_dir>` for the remainder of the tutorial. Wherever you see `<project_dir>`, replace it with the actual path to your project directory.

Follow [these instructions](https://github.com/clemsonciti/palmetto-examples/tree/master/PyTorch/Slurm) from the Palmetto Examples github repository to create a conda environment named `PytorchDDPExample` with the pytorch library installed. If you already have a suitable environment, you can use that instead. For this demo, you will also need the additional libraries in the `requirements.txt` file included with this example project.

Request an interactive job then perform the installation
```bash
$ salloc --cpus-per-task=8 --mem=16GB --time=1:00:00
$ srun --cpus-per-task=8 --mem=16GB --time=1:00:00 --pty bash
# wait for interactive job shell...

cd <project_dir>
module load anaconda3
source activate PytorchDDPExample
pip install -r requirements.txt

# terminate the job
exit
```

## Running in non-distributed mode
You can run the training script in non-distributed mode. This can be useful to test your setup and establish a timing baseline.
```bash
# Resource request. Tweak as needed for your custom script.
salloc --cpus-per-task=16 --mem=32GB --gpus=v100:1 --time=1:00:00
srun --cpus-per-task=16 --mem=32GB --gpus=v100:1 --time=1:00:00 --pty bash
# wait for interactive job shell...

cd <project_dir>
module load anaconda3
source activate PytorchDDPExample
time python train.py --epochs 5

# terminate the job
exit
```
The `time` command outputs three numbers. The number labeled `real` records the total walltime from start to finish. In our tests, execution took 2m31s.  

## Single-node, multi-gpu
We can use Pytorch's `torchrun` command-line tool to distribute training over multiple GPUs on a single node. 
```bash
# Resource request. Tweak as needed for your custom script.
salloc -N1 --cpus-per-task=16 --mem=32GB --gpus=v100:2 --time=1:00:00
srun -N1 --cpus-per-task=16 --mem=32GB --gpus=v100:2 --time=1:00:00 --pty bash
# wait for interactive job shell...

cd <project_dir>
module load anaconda3
source activate PytorchDDPExample

# type the command "hostname" into your terminal
# copy paste the output in place of $HOSTNAME below
time torchrun \
    --nnodes=1 \
    --nproc_per_node=2 \
    --rdzv_id=12345 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$HOSTNAME:3000 \
    train.py --ddp --epochs 5

# terminate the job
exit
```
In our tests, execution on 2 GPUs took 1m51s.

## Multi-node, multi-gpu
In order to execute on multiple nodes, the `torchrun` command needs to be run on each node with identical arguments. Since we also need to load anaconda and activate the environment, we need to define a small helper script (`helper.sh` in this example project).

This helper script takes the following arguments: 

1. Hostname of the primary node
2. Project working directory
3. Number of nodes
4. Number of GPUs per node
5. Number of training epochs

Please note that `helper.sh` includes the name of the environment `PytorchDDPExample`. If you have a different environment name, you will need to update the script accordingly.

Using this script, you can train for e.g. 5 epochs using 2-nodes and 2 GPUs per node job as follows:
```bash
# Resource request. Tweak as needed for your custom script.
salloc -N2 --cpus-per-task=16 --mem=32GB --gpus=v100:4 --time=1:00:00
# wait for interactive job shell...

cd <project_dir>

# use the following in place of $HOSTNAME: node(NODE_NUM).palmetto.clemson.edu
# Must replace (NODE_NUM) with the node number of an allocated node from salloc
time srun -N2 --cpus-per-task=16 --mem=32GB --gpus=v100:4 bash helper.sh $HOSTNAME ./ 2 2 5

# terminate the job
exit
```
In our tests, execution on 2 nodes with 2 GPUs each took 1m36s.

## Running as a batch job
Once you have your code working, it is usually more convenient to run long Pytorch training jobs as batch jobs instead of interactive jobs. To execute the 2-node, 2-gpu-per-node training job that we ran above as a batch job, create a new file (called `train.sh`, for example) with the following contents:
```bash
#!/bin/bash
#SBATCH -N2
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=32GB
#SBATCH --gpus=v100:4

HOSTNAME=$(hostname)
source activate PytorchDDPExample
cd <project_dir>
time srun -N2 --cpus-per-task=16 --mem=32GB --gpus=v100:4 bash helper.sh $HOSTNAME ./ 2 2 5
```
Execute the job from the login node using
```
touch output.txt
sbatch -N2 --cpus-per-task=16 --mem=32GB --gpus=v100:4 --output=output.txt train.sh
```
 Read more about batch jobs including information about how to monitor job status in [the palmetto documentation](https://docs.rcd.clemson.edu/palmetto/jobs/types#batch-jobs). 
