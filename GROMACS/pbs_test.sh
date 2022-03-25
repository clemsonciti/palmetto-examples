#!/bin/bash
#PBS -N GROMACS
#PBS -l select=4:ncpus=8:mpiprocs=2:ngpus=2:gpu_model=v100:interconnect=hdr:mem=22gb
#PBS -j oe
#PBS -l walltime=72:00:00

module purge
module load gromacs/2020.2-gcc/8.3.1-mpi-openmp-dp-cuda10_2

# Gromacs recommends having between 2 and 6 threads; let's set it to 4
export OMP_NUM_THREADS=4

cd $PBS_O_WORKDIR

# get the number of MPI processes
N_MPI_PROCESSES=`cat $PBS_NODEFILE | wc -l`

mpirun -np $N_MPI_PROCESSES -npernode 2 gmx_mpi mdrun -s nvt_e1-10.tpr -deffnm example
