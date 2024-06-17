#!/bin/bash
#SBATCH --job-name COMSOL
#SBATCH --nodes 2 
#SBATCH --ntasks 8
#SBATCH --cpus-per-task 1
#SBATCH --mem 32gb
#SBATCH --time 01:30:00

module purge
module load comsol/6.2

cd $SLURM_SUBMIT_DIR

comsol batch -mpibootstrap slurm -tmpdir $TMPDIR -inputfile free_convection.mph -outputfile free_convection_output.mph
