#!/bin/bash
#
#PBS -N mathematica
#PBS -l select=1:ncpus=1:mem=5gb
#PBS -l walltime=1:00:00
#

module load mathematica/10.0 

cd ${PBS_O_WORKDIR}

math -run "<<Example.m" > output.txt




