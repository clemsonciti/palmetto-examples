#!/bin/bash

#PBS -N NAMD-Example
#PBS -l select=2:ncpus=2:mem=10gb:interconnect=any:ngpus=1:gpu_model=any
#PBS -l walltime=2:00:00
#PBS -j oe

module load namd/2.14

cd $PBS_O_WORKDIR
mpirun namd2 +ppn 1 alanin > alanin.output
