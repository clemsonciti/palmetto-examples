#!/bin/bash 

#PBS -N qe-example 
#PBS -l select=2:ncpus=2:mpiprocs=2:ngpus=2:interconnect=fdr:mem=10gb
#PBS -l walltime=00:30:00
#PBS -j oe

module load espresso/5.4

cd $PBS_O_WORKDIR

# non-GPU version
mpirun pw.x < atom.in > qe-non-gpu.output

# GPU version
mpirun pw-gpu.x < atom.in > qe-gpu.output
