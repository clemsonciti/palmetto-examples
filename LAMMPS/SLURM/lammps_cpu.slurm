#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
#SBATCH --mem=16GB
#SBATCH --time=1:00:00

module load openmpi/5.0.1

export PATH=/home/$USER/software_slurm/lammps-2Aug2023/build-openmpi-omp:$PATH

cd $SLURM_SUBMIT_DIR

mpirun --bind-to core -np $SLURM_NTASKS lmp -in in.lj.txt
