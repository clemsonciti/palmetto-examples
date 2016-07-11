# Compiling and running MPI programs on palmetto

In this example,
we demonstrate how to compile and run
MPI-enabled code on the Palmetto cluster.
The program `pi_mpi.c` can be run in a distributed fashion
(several CPU cores spanning several compute nodes)
using MPI.
The larger the number of CPU cores used,
the better the estimate of pi the program produces.
Following are the steps to compile this program
and submit a job that runs it.

1.  Request hardware.
    The Palmetto cluster is composed of several phases,
    each consisting of compute nodes connected by
    different types of interconnect
    (Myrinet, Infiniband, Ethernet).
    The `interconnect` option can be used as part of the
    resource limit specifications
    to specify which interconnect is to be used:

        interconnect=1g   (1 Gbps Ethernet)
        interconnect=10g   (10 Gbps Myrinet, same as mx)
        interconnect=10ge   (10 Gbps Ethernet)
        interconnect=40g   (40 Gbps QDR InfiniBand, same as qdr)
        interconnect=56g   (56 Gbps QDR InfiniBand, same as fdr)
        interconnect=mx   (10 Gbps Myrinet, same as 10g)
        interconnect=qdr   (40 Gbps QDR InfiniBand, same as 40g)
        interconnect=fdr   (56 Gbps QDR InfiniBand, same as 56g)

    Thus, the following interactive job request
    asks for 4 resource chunks, with 4 CPU cores each,
    and 56g QDR InfiniBand interconnect:

        qsub -I -l select=4:ncpus=4:mpiprocs=4:interconnect=56g,walltime=1:00:00

2.  Load the required modules:

        module load gcc/4.8.1 openmpi/1.8.4

2.  Compile the code:
    If you use any optimization flags (e.g., `-O2, -O3`)
    when compiling on a compute node,
    you will probably have to run your code on a similar compute node.
    Running on a compute node with an older generation of processor
    will likely fail.

        mpicc pi_mpi.c -o pi.x 

3.  Log out of the compute node, and prepare/Verify the submit script.
    OpenMPI on Palmetto is aware of all PBS variables.
    There is no need to specify the number of processes with `mpirun`.
    OpenMPI will automatically parse the `$PBS_NODEFILE` file and
    select the appropriate number of MPI processes to use.
    To make sure that 
    all CPU cores will be used for MPI processes,
    use `mpiprocs` equal to `ncpus`
    in the hardware request line of the PBS script, e.g.,

        #PBS -l select=2:ncpus=16:mpiprocs=16

    will allow `mpirun` to start 32 processes.
    You may still explicitly specify
    the number of MPI processes to use:

        mpirun -n 2 ./application.x

4.  Submit the job

        qsub job.sh
