# GROMACS

- Gromacs is an architecture-specific software. It performs best when installed and configured for the
specific hardware. In the following, we present how to install/compile GROMACS for specific hardware manually. 

- Followed by intallation, you we can run some test jobs. We provided some examples below. 
But if you have your own input settings, we encourage you to test your input file.
If you don't have an input file you can create one from the GROMACS benchmarks. 

## Automatic Installation
The easiest way is to use the `gmx_install.slurm` script in this repo. Simply download it to your account and submit a batch job using `sbatch gmx_install.slurm`. The Gromacs will be installed at `/home/$USER/software_slurm/Gromacs`...

If you are curious about the installation, you can read the next setion.

### Installation Process
 - To simplify the process of setting up gromacs, we recommend that you use existing modules on Palmetto2, such as Intel-MKL, openmpi, etc.

 - Get a node (choose the node type you wish to run Gromacs on)
 ```
 $ salloc --nodes=1 --ntasks-per-node=12 --gpus-per-node=1 --mem=20G --time=01:00:00
 ```
 - Creating a local software directory

 If you have not created a `software` directory, you can do it under your home directory by:

 ~~~
 $ cd ~
 $ mkdir software_slurm
 ~~~

 - Get Gromacs Source Code
 The source code of Gromacs can be downloaded from https://manual.gromacs.org/documentation/current/download.html. For simplicity, one can use the following commands to download the     `2024.2` version:

 ~~~
 $ wget https://ftp.gromacs.org/gromacs/gromacs-2024.2.tar.gz
 $ tar zxvf https://ftp.gromacs.org/gromacs/gromacs-2024.2.tar.gz
 $ cd gromacs-2024.2
 ~~~

 - Create build directory
 ~~~
 $ mkdir build_slurm
 $ cd build_slurm
 ~~~

 - Load available modules on Palmetto
 ~~~
 module use /software/ModuleFiles/modules/linux-rocky8-x86_64/
 module load anaconda3 gcc/9.5.0 intel-oneapi-mkl cuda/11.8.0 openmpi # gcc/9.5.0 is loaded from the old module file, but is not needed when running jobs
 ~~~
 - Identify architecture type and SIMD:

 This is because Gromacs depends greatly on the architechture of the hardware as mentioend at the beginning.

 ```
 $ lscpu | grep "Model name"
 ```
 Select the correct architecture based on the CPU model and corresponding SIMD:

 E5-2665: sandybridge (AVX_256)
 E5-2680: sandybridge (AVX_256)
 E5-2670v2: ivybridge (AVX_256)
 E5-2680v3: haswell (AVX2_256)
 E5-2680v4: broadwell (AVX2_256)
 6148G: skylake (AVX_512)
 6252G: cascadelake (AVX_512)
 6238R: cascadelake (AVX_512)
 6248: cascadelake (AVX_512)
 8358: icelake (AVX_512)

 In this example, given the previous `salloc` command, we most likely will get a node with `AVX_512`, which will be the input value for the below `-DGMX_SIMD`.

- Compiling Gromacs

 ~~~
 $ cmake .. -DGMX_MPI=on -DGMX_GPU=CUDA -DGMX_FFT_LIBRARY=mkl -DGMX_SIMD=AVX_512 -DCMAKE_INSTALL_PREFIX=/home/$USER/software_slurm/gromacs-2024.2/build_slurm/gmx
 $ make -j 12
 $ make install -j 12
 ~~~

## Running in batch mode

The most optimal way to run GROMACS on Palmetto is from a batch script which uses multiple nodes, multiple threads, and multiple GPUs (two per node) for faster performance. Here's an example (which uses `em.tpr` as the input, which needs to be in the same folder as the script, whose name can be `gmx_gpu.slurm`):

```
#!/bin/bash
#SBATCH --job-name=GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6
#SBATCH --gpus-per-node=2
#SBATCH --mem=22G
#SBATCH --time=0:15:00

cd $SLURM_SUBMIT_DIR

module purge
module load cuda/11.8.0 openmpi intel-oneapi-mkl

#Source the Gromacs environment variable
source /home/$USER/software_slurm/gromacs-2024.2/build_slurm/gmx/bin/GMXRC

# Gromacs recommends having between 2 and 6 threads:
export OMP_NUM_THREADS=6

# get the total number of MPI processes
echo number of MPI processes is $SLURM_NTASKS

# generate binary input file
srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

srun gmx_mpi mdrun -s em.tpr -deffnm job-output
```

Note that `cpus-per-task` should equal to `OMP_NUM_THREADS`; `ntasks-per-node` should equal to `gpus-per-node`.
You can also select more or less nodes with the `nodes` option when requesting resources; there is no need to change other parameters because they will be automatically adjusted to the number of nodes.

Once we have the Slurm submission script (`gmx_gpu.slurm`) and all the input files ready, we can sumbit the batch job with the pre-built GROMACS using the following command:

~~~
sbatch gmx_gpu.slurm
~~~

For a simple test, we can use the ADH benchmark inputs, and then we can do the following steps to submit a Gromacs job.
~~~
$ mkdir -p /scratch/$USER/gromacs_ADH_benchmark_batch
$ cd /scratch/$USER/gromacs_ADH_benchmark_batch
$ wget ftp://ftp.gromacs.org/pub/benchmarks/ADH_bench_systems.tar.gz
$ tar -xzf ADH_bench_systems.tar.gz
$ cd ADH/adh_cubic
$ sbatch gmx_gpu.slurm
~~~

Once the job is done, we can find the following sentence in the output file `job-output.log`
~~~
This program was compiled for different hardware than you are running on,
which could influence performance.
~~~

We can use the following command to find the walltime/efficiency of the job.
~~~
tail -n 6 job-output.log | head -n 4
~~~
And it returns:
~~~
               Core t (s)   Wall t (s)        (%)
       Time:     1632.272      136.024     1200.0
                 (ns/day)    (hour/ns)
Performance:       12.705        1.889
~~~

More information on GROMACS performance optimisation can be found [here.](https://manual.gromacs.org/documentation/current/user-guide/mdrun-performance.html)

## Running in interactive mode

As an example, we'll consider running the GROMACS ADH benchmark as in the pre-built case above.

First, request an interactive job if you exited the compute node from the above installation step:

~~~
$ salloc --nodes=1 --ntasks-per-node=1 --cpus-per-task=10 --gpus-per-node=a100:1 --mem=20G --time=01:00:00
~~~

We need to download the benchmark test inputs, and then we can do the following steps to run Gromacs interactively.

~~~
$ mkdir -p /scratch/$USER/gromacs_ADH_benchmark
$ cd /scratch/$USER/gromacs_ADH_benchmark
$ wget ftp://ftp.gromacs.org/pub/benchmarks/ADH_bench_systems.tar.gz
$ tar -xzf ADH_bench_systems.tar.gz
$ cd ADH/adh_cubic
$ source /home/$USER/software_slurm/gromacs-2024.2/build_slurm/gmx/bin/GMXRC
$ export OMP_NUM_THREADS=10
$ module load cuda/11.8.0 openmpi intel-oneapi-mkl
$ srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr
$ srun gmx_mpi mdrun -s em.tpr -deffnm job-output
~~~

After the last command above completes,
the `.edr` and `.log` files produced by GROMACS should be visible.
Typically, the next step is to copy these results to the
output directory, e.g. home directory.

