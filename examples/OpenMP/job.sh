#!/bin/bash

#PBS -N hello
#PBS -l select=1:ncpus=8:mem=1gb:interconnect=1g
#PBS -l walltime=00:05:00
#PBS -j oe

module add gcc/4.8.1

cd $PBS_O_WORKDIR

## OMP_NUM_THREADS is set automatically by PBS in resource limits
## based on the value of ncpus (ncpus=ompthreads).

#export OMP_NUM_THREADS=1

./hello.x
