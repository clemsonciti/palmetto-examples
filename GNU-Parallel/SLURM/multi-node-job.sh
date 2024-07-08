#!/bin/bash

#SBATCH --job-name=gnu-parallel-example
#SBATCH --nodes=5
#SBATCH --tasks-per-node=4:
#SBATCH --mem=1G
#SBATCH --time=00:05:00

module load parallel

cd $SLURM_SUBMIT_DIR

srun hostname > nodes.txt
ls ./inputs/* | parallel --sshloginfile nodes.txt -j4 'module add anaconda3; cd /home/username/GNU-Parallel; python transpose.py {}'
rm nodes.txt
