#!/bin/bash
#PBS -N ANSYSdis
#PBS -l select=2:ncpus=4:mpiprocs=4:mem=11gb:interconnect=mx
#PBS -l walltime=1:00:00
#PBS -j oe

module purge
module add ansys/17.2

cd $PBS_O_WORKDIR

machines=$(uniq -c $PBS_NODEFILE | awk '{print $2":"$1}' | tr '\n' :)

SCRATCH=/local_scratch/$USER

for node in `uniq $PBS_NODEFILE`
do
    ssh $node "mkdir -p $SCRATCH"
    ssh $node "cp input.txt $SCRATCH"
done

ansys172 -dir $SCRATCH -j EXAMPLE -s read -l en-us -b -i input.txt -o output.txt -dis -machines $machines -usessh

sleep 60

for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
    ssh $node "rm -rf $SCRATCH"
done
