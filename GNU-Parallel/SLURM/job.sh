#!/bin/bash

#SBATCH --job-name gnu-parallel-example
#SBATCH --nodes=1
#SBATCH --tasks-per-node=4
#SBATCH --mem=1G
#SBATCH --time=00:05:00

cd $SLURM_SUBMIT_DIR
module load parallel
module add anaconda3

# process all files in inputs/ directory, 4 at a time:
ls ./inputs/* | parallel -j4 python transpose.py

# if the input files are specified in "inputs.txt", we can do:
# parallel -j4 python transpose.py < inputs.txt
