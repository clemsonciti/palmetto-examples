#!/bin/bash
#PBS -N ANSYSdis
#PBS -l select=2:ncpus=4:mpiprocs=4:mem=11gb:interconnect=any
#PBS -l walltime=1:00:00
#PBS -j oe

module purge
module add ansys/19.5

pbsdsh sleep 20

cd $PBS_O_WORKDIR

machines=$(uniq -c $PBS_NODEFILE | awk '{print $2":"$1}' | tr '\n' :)

SCRATCH=$TMPDIR

for node in `uniq $PBS_NODEFILE`
do
    ssh $node "mkdir -p $SCRATCH"
    ssh $node "cp $PBS_O_WORKDIR/input.txt $SCRATCH"
done

cd $SCRATCH

ansys195 -dir $SCRATCH -j EXAMPLE -s read -l en-us -b -i input.txt -o output.txt -dis -machines $machines -usessh

sleep 60

for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
    ssh $node "rm -rf $SCRATCH"
done
