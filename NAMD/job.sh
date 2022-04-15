#!/bin/bash

#PBS -N NAMD-Example
#PBS -l select=2:ncpus=10:mem=10gb:mpiprocs=1:interconnect=fdr:ngpus=1:gpu_model=any
#PBS -l walltime=2:00:00
#PBS -j oe

module load namd/2.14

cd $PBS_O_WORKDIR
mpirun -np 2 namd2 +ppn 9 +setcpuaffinity +idlepoll alanin > alanin.output

# In this example, we use 2 nodes, 10 CPUs per node, 10 GB of RAM per node, 1 GPU per node, and FDR interconect.
# Feel free to increase the number of nodes. Make sure they match the -np setting after mpirun. For example,
# "select=10" will request 10 nodes, so you will need to have "mpirun -np 10".
# Feel free to increase the number of CPUs; this will need to match the +ppn setting of namd2. For example,
# requesting "ncpus=20" means that you will have to set "namd2 +ppn 19".
# In general, the +ppn setting isnumber of CPUs minus one. This is the number of parallel processes per node.
# Feel free to increase the amount of RAM (see /etc/hardware-table) if needed. Increasing the number of GPUs doesn't seem to help.
# I recommend keeping mpiprocs set to one.
# Feel free to set interconnect to hdr (will be faster but you might have to wait in queue and you might get preempted).
# However, do NOT set interconnect=any, because you want to be sure that the nodes have the same type of interconnect 
# (otherwise mpirun might not work properly). 
# Finally, feel free to specify a particular GPU type.
# That's all folks. Grigori Yourganov gyourga@clemson.edu
