# Compiling and running MPI programs on palmetto

In this example, we demonstrate how to compile and run MPI-enabled
code on the Palmetto 2 cluster.  The program `pi_mpi.c` can be run
in a distributed fashion (several CPU cores spanning several compute
nodes) using MPI. The larger the number of CPU cores used, the
better the estimate of pi the program produces. Following are the
steps to compile this program and submit a job that runs it.

1.  Request hardware.
    The Palmetto 2 cluster is composed of several phases, each
    consisting of compute nodes connected by different types of
    interconnect (Infiniband, Ethernet).  

    The following interactive job request asks for 4 nodes , with 4 tasks 
    (cpu cores) on each node.

	salloc --nodes=4 --tasks-per-node=4 --time=01:00:00

2.  Load the required modules:

	module load openmpi/5.0.1

2.  Compile the code:
    If you use any optimization flags (e.g., `-O2, -O3`) when
    compiling on a compute node, you will probably have to run your
    code on a similar compute node.  Running on a compute node with
    an older generation of processor will likely fail.

	mpicc pi_mpi.c -o pi.x

3.  Log out of the compute node, and prepare the submit script.
    OpenMPI on Palmetto is aware of all SLURM variables.  There is
    no need to specify the number of processes with `mpirun`.
    OpenMPI will automatically parse the `$SLURM_NODELIST` file and
    select the appropriate number of MPI processes to use.  
    
    It is recommended to use `srun` to launch the application, .e.g `srun pi.x`,
    where the selection of nodes and tasks will be passed automatically.

    You may still explicitly specify the number of MPI processes to use:

	srun --tasks-per-node=2 ./application.x

    (You may still be able to run the old `mpirun` command.)

4.  Submit the job

	sbatch job.slurm
