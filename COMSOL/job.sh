#!/bin/bash
#PBS -N COMSOL
#PBS -l select=1:ncpus=8:mem=32gb,walltime=01:30:00
#PBS -j oe

module purge
module add comsol/5.5

cd $PBS_O_WORKDIR
SCRATCH=$TMPDIR

comsol batch -np 8 -tmpdir /$SCRATCH -inputfile free_convection.mph -outputfile free_convection_output.mph
