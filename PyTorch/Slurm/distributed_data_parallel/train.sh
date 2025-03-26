#!/bin/bash
#SBATCH -N2
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=32GB
#SBATCH --gpus=v100:4

export HOSTNAME=$(hostname)
source activate PytorchDDPExample
cd /path/to/your/project
time srun -N2 --cpus-per-task=16 --mem=32GB --gpus=v100:4 bash helper.sh $HOSTNAME ./ 2 2 5
