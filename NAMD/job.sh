#!/bin/bash

#PBS -N NAMD2-test
#PBS -l select=2:ncpus=2:mpiprocs=1:interconnect=fdr:mem=2gb
#PBS -l walltime=1:00:00
#PBS -j oe

module load namd/20150610-intel

cd $PBS_O_WORKDIR
mpirun namd2 +ppn 2 alanin > alanin.output
