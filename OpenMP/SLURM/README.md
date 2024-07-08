## Using OpenMP-enabled programs

In this example, we demonstrate a simple example of using OpenMP
in your code, how to compile OpenMP-enabled programs, and how to
run them.  The program `hello_world_openmp.c` is a simple multi-threaded
program that instructs each thread to print a message.  `job.pbs`
is a job script that calls the executable created after compiling
the program.

1.  Request an interactive job.
All compilation should be done on a compute node.

        salloc --nodes=1 --tasks-per-node=1 --cpus-per-task=4 --time=00:10:00

2.  Load modules needed for compilation

        module load gcc/12.3.0

3.  Compile the code with OpenMP.
If you use any optimization flags (e.g., `-O2, -O3`) when
compiling on a compute node, you will probably have to run your
code on a similar compute node.  Running on a compute node with
an older generation of processor will likely fail.

        gcc -fopenmp hello_world_openmp.c -o hello.x

4.  Log out of the compute node and
prepare/verify the submit script `job.slurm`.  The variable
controlling the number of OpenMP threads i.e. `OMP_NUM_THREADS`
is automatically set on Palmetto 2 to the requested number of
cpus per task (`--cpus-per-task`).  To change it, use the following
command

        export OMP_NUM_THREADS=x

where `x` is the number of requested threads.

5.  Submit the job

        sbatch job.slurm

