#!/bin/bash

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=20
#SBATCH --cpus-per-task=1
#SBATCH --time=1:0:0
#SBATCH --mem=10G
#SBATCH --job-name abaqus_test

module load abaqus anaconda3

python get_env.py

INPUT=test_run.inp

abq2023 inp=$INPUT job=test_run mp_mode=mpi cpus=$SLURM_NTASKS scratch=$SLURM_SUBMIT_DIR interactive
