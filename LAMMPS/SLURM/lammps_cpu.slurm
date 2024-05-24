#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=8
#SBATCH --mem=12GB
#SBATCH --time=1:00:00

module load openmpi/5.0.1

export PATH=/home/$USER/software_slurm/lammps-2Aug2023/build-openmpi-omp:$PATH

cd $SLURM_SUBMIT_DIR

srun lmp -sf omp -pk omp 8 -in in.lj.txt
