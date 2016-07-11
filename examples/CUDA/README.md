# Compiling and running CUDA programs on Palmetto

In this example,
we demonstrate how to compile and run
CUDA-enabled code on the Palmetto cluster.
The program `add_vectors.cu` leverages GPUs
to add two vector together in parallel.

1.  Request hardware.
    To request GPUs, simply use the `ngpus=` option in
    your resource limits specification.
    Each GPU node has 2 GPUs,
    so you cannot request more than 2 GPUs per hardware chunk.
    You can also specify the GPU model
    using `gpu_model` (for example, `gpu_model=k20` or `gpu_model=k40`).

        qsub -I -l select=1:ncpus=1:ngpus=1:gpu_model=k20,walltime=1:00:00

2.  Load the required modules:

        module load cuda-toolkit/7.0.28

2.  Compile the code;
    CUDA-enabled programs can be compiled using the `nvcc` compiler:

        nvcc -o add.x add_vectors.cu

3.  Log out of the compute node, and prepare/verify the submit script.
    The modules used when compiling the program must be loaded
    at runtime. So, ensure the following line is in `job.sh`:

        module add cuda-toolkit/7.0.28

4.  Submit the job

        qsub job.sh
