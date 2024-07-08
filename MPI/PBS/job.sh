#!/bin/bash

#PBS -N pi-mpi
#PBS -l select=2:ncpus=16:mem=2gb:interconnect=1g:mpiprocs=2
#PBS -l walltime=00:05:00
#PBS -j oe

module add gcc/4.8.1 openmpi/1.8.4
cd $PBS_O_WORKDIR
mpirun -n 8 ./hello
