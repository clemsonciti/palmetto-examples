#!/bin/bash

#SBATCH --job-node=pi-mpi
#SBATCH --nodes=2
#SBATCH --tasks-per-node=16
#SBATCH --mem=2G
#SBATCH --time=00:05:00

module add openmpi/5.0.1

cd $SLURM_SUBMIT_DIR
srun ./hello
