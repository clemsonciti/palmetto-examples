#PBS -N gnu-parallel-example
#PBS -l select=1:ncpus=4:mem=1gb,walltime=00:05:00

cd $PBS_O_WORKDIR
module add gnu-parallel
module add anaconda3/4.2.0

# process all files in inputs/ directory, 4 at a time:
ls ./inputs/* | parallel -j4 python transpose.py

# if the input files are specified in "inputs.txt", we can do:
# parallel -j4 python transpose.py < inputs.txt
