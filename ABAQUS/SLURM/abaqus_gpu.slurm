#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --cpus-per-task=1
#SBATCH --time=1:0:0
#SBATCH --mem=10G
#SBATCH --gpus-per-node=1
#SBATCH --job-name IS_40_Multi2

module load abaqus 

INPUT=IS_40_Multi2.inp

abq2023 inp=$INPUT job=IS_40_Multi2 mp_mode=mpi cpus=$SLURM_NTASKS scratch=$SLURM_SUBMIT_DIR gpus=1 interactive

