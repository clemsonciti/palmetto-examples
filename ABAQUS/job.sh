#!/bin/bash
#PBS -N AbaqusDemo
#PBS -l select=2:ncpus=8:mpiprocs=8:mem=6gb:interconnect=mx,walltime=00:15:00
#PBS -j oe

module purge
module add abaqus/6.14

NCORES=`wc -l $PBS_NODEFILE | gawk '{print $1}'`
cd $PBS_O_WORKDIR

# SSH into each node and create the scratch directory
for node in `uniq $PBS_NODEFILE`
do
    SCRATCH=/local_scratch/$USER
    ssh $node "mkdir $SCRATCH"
done

# run the abaqus program, providing the .inp file as input
abaqus job=abdemo double input=/scratch2/$USER/ABAQUS/boltpipeflange_axi_solidgask.inp scratch=$SCRATCH cpus=$NCORES mp_mode=mpi interactive 

# SSH into each node and remove the scratch directory
for node in `uniq $PBS_NODEFILE`
do
    SCRATCH=/local_scratch/$USER
    ssh $node "rm -rf $SCRATCH"
done
