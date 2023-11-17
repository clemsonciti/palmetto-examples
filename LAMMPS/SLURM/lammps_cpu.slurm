#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=8
#SBATCH --mem=12GB
#SBATCH --time=1:00:00

module load openmpi/4.1.5

export PATH=/home/$USER/software_slurm/lammps-23Jun2022/build-openmpi-omp:$PATH

cd $SLURM_SUBMIT_DIR

srun lmp -sf omp -pk omp 8 -in in.lj.txt
