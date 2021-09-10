#!/bin/bash

#PBS -N CP2K-Example
#PBS -l select=2:ncpus=10:mem=10gb:mpiprocs=10:interconnect=fdr:ngpus=1:gpu_model=any
#PBS -l walltime=2:00:00
#PBS -j oe

module load cp2k/7.1-gcc/7.1.0-mpi-openmp-cuda10_2
export NPROCS=`wc -l $PBS_NODEFILE |gawk '//{print $1}'`

cd $PBS_O_WORKDIR
mpirun -np $NPROCS cp2k.psmp argon.inp > output.txt

# Feel free to ask for more CPUs per node, or more memory, or more nodes.
# Make sure mpiprocs is set to the same number as ncpus.
# Feel free to set interconnect to "hdr" (but not to "1g" or "any").
# Grigori Yourganov gyourga@clemson.edu
