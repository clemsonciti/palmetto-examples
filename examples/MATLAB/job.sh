#!/bin/bash
#
#PBS -N test_matlab
#PBS -l select=1:ncpus=1:mem=5gb
#PBS -l walltime=1:00:00
#

module add matlab/2014a

cd $PBS_O_WORKDIR

taskset -c 0-$(($OMP_NUM_THREADS-1)) matlab -nodisplay -nodesktop -nosplash -r test > test_results.txt




