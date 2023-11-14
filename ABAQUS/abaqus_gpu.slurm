#!/bin/bash
#SBATCH --job-name=abaqus_test
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-node=a100:1
#SBATCH --mem=12gb
#SBATCH --time=2:00:00
#SBATCH --output=abaqus_test.%j.out
#SBATCH --error=abaqus_test.%j.err

module use /software/AltModFiles
module load abaqus/2023

cd $SLURM_SUBMIT_DIR

srun abaqus job=abaqus_test input=boltpipeflange_axi_solidgask.inp scratch=$SLURM_SUBMIT_DIR cpus=$SLURM_CPUS_PER_TASK mp_mode=mpi interactive

