#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --mem=32GB
#SBATCH --time=1:00:00
#SBATCH --constraint=cpu_gen_genoa

module load aocc lammps

cd $SLURM_SUBMIT_DIR

mpirun --bind-to core -np $SLURM_NTASKS lmp -in in.lj.txt
