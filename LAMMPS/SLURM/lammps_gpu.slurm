#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --gpus-per-node=v100:2
#SBATCH --mem=12GB
#SBATCH --time=1:00:00

module load cuda openmpi/5.0.1

export PATH=/home/$USER/software_slurm/lammps-2Aug2023/build-kokkos-gpu-omp:$PATH

cd $SLURM_SUBMIT_DIR

mpirun --bind-to core -np $SLURM_NTASKS lmp -sf gpu -pk gpu 2 -in in.lj.txt
