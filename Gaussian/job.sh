#!/bin/bash
#
#PBS -N g09
#PBS -l select=1:ncpus=2
#PBS -l walltime=0:10:00

# ------------------------
# user prepared input file
input=ch4.inp
# ------------------------

filename=`basename $input .inp`

module load gaussian/g09

cd $TMPDIR

cp $PBS_O_WORKDIR/$input .

g09 $input

cp $filename.log $PBS_O_WORKDIR
