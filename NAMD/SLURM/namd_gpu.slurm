#!/bin/bash

#SBATCH --job-name NAMD-gpu
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=10G
#SBATCH --time=2:00:00
#SBATCH --gpus-per-node=1

module load namd/3.06b

cd $SLURM_SUBMIT_DIR

srun namd3 +ppn 8 +netpoll equil_min.namd > min.out
srun namd3 +ppn 8 +netpoll equil_k0.5_gpu.namd > namd.output

