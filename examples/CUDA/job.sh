#/bin/bash
#PBS -N cuda
#PBS -l select=1:ncpus=1:ngpus=1:mem=1gb:interconnect=1g
#PBS -l walltime=00:05:00

module add cuda-toolkit/7.0.28
cd $PBS_O_WORKDIR
./add.x
