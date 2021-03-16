#PBS -N gnu-parallel-example
#PBS -l select=5:ncpus=4:mem=1gb,walltime=00:05:00

module add gnu-parallel/20200722

cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodes.txt
ls ./inputs/* | parallel --sshloginfile nodes.txt -j4 'module add anaconda3/4.2.0; cd /home/username/GNU-Parallel; python transpose.py {}'
rm nodes.txt
