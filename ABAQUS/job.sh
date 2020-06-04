#!/bin/bash
#PBS -N AbaqusDemo
#PBS -l select=2:ncpus=8:mpiprocs=8:mem=6gb:interconnect=1g,walltime=00:15:00
#PBS -j oe

module purge
module add abaqus/6.14

pbsdsh sleep 20

NCORES=`wc -l $PBS_NODEFILE | gawk '{print $1}'`
cd $PBS_O_WORKDIR

SCRATCH=$TMPDIR

# SSH into each node and create the scratch directory
# copy all input files into the scratch directory
for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp $PBS_O_WORKDIR/*.inp $SCRATCH"
done

cd $SCRATCH

# run the abaqus program, providing the .inp file as input
abaqus job=abdemo double input=$SCRATCH/boltpipeflange_axi_solidgask.inp scratch=$SCRATCH cpus=$NCORES mp_mode=mpi interactive 

# SSH into each node and remove the scratch directory
for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
done
