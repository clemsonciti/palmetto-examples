#!/bin/bash

#SBATCH --job-name=test_matlab
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=5G
#SBATCH --time=1:00:00

module add matlab/2023b

cd $SLURM_SUBMIT_DIR

matlab -nodisplay -nodesktop -nosplash -r test > test_results.txt

