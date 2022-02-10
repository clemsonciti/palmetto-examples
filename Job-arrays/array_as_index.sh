#!/bin/bash

#PBS -N arrayIndex
#PBS -l select=1:ncpus=1:interconnect=1g
#PBS -l walltime=00:02:00
#PBS -j oe
#PBS -J 1-4

cd $PBS_O_WORKDIR

numArr=(2 5 6 8)

i=$((${PBS_ARRAY_INDEX}-1))

echo "Parameter is " ${numArr[$i]}

