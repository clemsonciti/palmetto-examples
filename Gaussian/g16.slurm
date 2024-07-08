#!/bin/bash

#SBATCH --job-name=g16
#SBATCH --nodes=1 
#SBATCH --tasks-per-node=2
#SBATCH --mem=4G
#SBATCH --time=0:10:00

# ------------------------
# user prepared input file
input=ch4.inp
# ------------------------

filename=`basename $input .inp`

module load gaussian/g16-avx2

cd $SLURM_SUBMIT_DIR
export GAUSS_SCRDIR=$TMPDIR

g16 $input > $filename.log
