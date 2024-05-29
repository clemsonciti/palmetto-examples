#!/bin/bash

#PBS -N NAMD-Example
#PBS -l select=1:ncpus=2:mem=10gb:interconnect=any:ngpus=1:gpu_model=any
#PBS -l walltime=2:00:00
#PBS -j oe

module load namd/2.14

cd $PBS_O_WORKDIR
namd2 +idlepoll +p2 +devices 0 alanin > alanin.output

# this example runs NAMD2 on two cores (corresponding to ncpus=2 in #PBS -l line)
# if you need to run it on mode cores, say 10, specify ncpus=10 in #PBS -l line and +p10 in the namd2 line
# also, this example runs on one GPU (ngpus=1 in #PBS -l line)
# to run it on two GPUs, set ngpus=2 in the #PBS -l line,
# and specify +devices 0,1 in the namd2 line
