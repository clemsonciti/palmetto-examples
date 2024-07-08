#!/bin/bash

#SBATCH --job-name=hello
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=1G
#SBATCH --time=00:05:00

module add gcc/12.3.0

cd $SLURM_SUBMIT_DIR

## OMP_NUM_THREADS is set automatically by PBS in resource limits
## based on the value of ncpus (cpus-per-task=ompthreads).

#export OMP_NUM_THREADS=1

./hello.x
