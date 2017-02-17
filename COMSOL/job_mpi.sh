#!/bin/bash
#PBS -N COMSOL
#PBS -l select=2:ncpus=8:mpiprocs=8:mem=32gb,walltime=01:30:00
#PBS -j oe

module purge
module add comsol/5.2

cd $PBS_O_WORKDIR

uniq $PBS_NODEFILE > comsol_nodefile
comsol batch -clustersimple -f comsol_nodefile -tmpdir /local_scratch -inputfile free_convection.mph -outputfile free_convection_output.mph
