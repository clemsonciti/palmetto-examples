#!/bin/bash

#PBS -N quadratic
#PBS -l select=1:ncpus=1:interconnect=1g
#PBS -l walltime=00:02:00
#PBS -j oe
#PBS -J 1-8

cd $PBS_O_WORKDIR

inputs=( $(sed -n ${PBS_ARRAY_INDEX}p inputs.txt) )

./quadratic.py ${inputs[0]} ${inputs[1]} ${inputs[2]}
