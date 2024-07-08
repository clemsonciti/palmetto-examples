## Using OpenMP-enabled programs

In this example, we demonstrate a simple example of using OpenMP
in your code, how to compile OpenMP-enabled programs, and how to
run them.  The program `hello_world_openmp.c` is a simple multi-threaded
program that instructs each thread to print a message.  `job.pbs`
is a job script that calls the executable created after compiling
the program.

1.  Request an interactive job.
All compilation should be done on a compute node.

        qsub -I -l select=1:ncpus=1,walltime=2:00:00

2.  Load modules needed for compilation

        module load gcc/4.8.1

3.  Compile the code with OpenMP.
If you use any optimization flags (e.g., `-O2, -O3`) when
compiling on a compute node, you will probably have to run your
code on a similar compute node.  Running on a compute node with
an older generation of processor will likely fail.

        gcc -fopenmp hello_world_openmp.c -o hello.x

4.  Log out of the compute node and
prepare/verify the submit script `job.pbs`.  The variable
controlling the number of OpenMP threads i.e. `OMP_NUM_THREADS`
is automatically set on Palmetto to the requested number of
cores per node (`ncpus`).  To change it, use the following
command

        export OMP_NUM_THREADS=x

where `x` is the number of requested threads.

5.  Submit the job

        qsub job.sh

