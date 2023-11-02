# GROMACS

- Gromacs is an architecture-specific software. It performs best when installed and configured for the
specific hardware. On Palmetto, we still provide several general versions of GROMACS which can be loaded by all users. Since the general versions are optimized for specific hardware, the performance might be degraded. In the following, we present how to use the pre-built general versions of GROMACS and how to install/compile GROMACS for specific hardware manually. 

## Using pre-built versions of GROMACS (WIP: will update this section once we have a prebuilt version)

Palmetto comes with different general versions of GROMACS installed as modules, these can be found with the module command

~~~
$ module use /software/ModuleFiles/modules/linux-rocky8-x86_64/
$ module avail gromacs
~~~

We recommend you use `gromacs/2021.5-gcc/9.5.0-openmpi/4.1.3-mpi-openmp-cu11_1` as it should work immediately with the test files. There are other modules available for different use cases.

### Node Selection

We recommend that you select a node that has a GPU to utilize the extra performance gained from using one. An example node could look something like this

```
$ salloc --nodes=1 --ntasks-per-node=6 --cpus-per-task=1 --gpus-per-node=a100:1 --mem=26G --time=00:20:00
```

Next we can load in our pre-built version of GROMACS from the module list

```
$ module use /software/ModuleFiles/modules/linux-rocky8-x86_64/
$ module load gromacs/2021.5-gcc/9.5.0-openmpi/4.1.3-mpi-openmp-cu11_1
```

If you have your own input settings you should compile them into an input file.

If you don't have an input file you can create one from the GROMACS benchmarks. In this following example we create the input binary with the name `em.tpr`.

```
$ wget ftp://ftp.gromacs.org/pub/benchmarks/ADH_bench_systems.tar.gz
$ tar zxvf ADH_bench_system.tar.gz
$ cd ADH/adh_cubic
$ srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr
```

You can then run your input (for example, `em.tpr`) file with `gmx_mpi`

```
$ srun gmx_mpi mdrun -s em.tpr -deffnm job_output
```

### Running in batch mode

The most optimal way to run GROMACS on Palmetto is from a batch script which uses multiple nodes, multiple threads, and multiple GPUs (two per node) for faster performance. Here's an example (which uses `em.tpr` as the input, which needs to be in the same folder as the script, whose name can be `gmx_pbs_prebuilt.sh`):

```
#!/bin/sh
#SBATCH --job-name=GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6
#SBATCH --gpus-per-node=a100:2
#SBATCH --mem=22G
#SBATCH --time=0:15:00

cd $SLURM_SUBMIT_DIR

module purge
module use /software/ModuleFiles/modules/linux-rocky8-x86_64/
module load gromacs/2021.5-gcc/9.5.0-openmpi/4.1.3-mpi-openmp-cu11_1

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

Once we have the PBS submission script (`gmx_slurm_prebuilt.sh`) and all the input files ready, we can sumbit the batch job with the pre-built GROMACS using the following command:

~~~
sbatch gmx_pbs_prebuilt.sh
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

## Manually Installing GROMACS

- To simplify the process of setting up gromacs, we recommend that you use existing modules on Palmetto, such as Intel-MKL, cmake, etc.

- Get a node (choose the node type you wish to run Gromacs on)

```
$ salloc --nodes=1 --ntasks-per-node=20 --cpus-per-task=1 --gpus-per-node=a100:1 --mem=20G --time=01:00:00
```
- Creating a local software directory

If you have not created a `software` directory, you can do it under your home directory by:

~~~
$ cd ~
$ mkdir software
~~~

- Get Gromacs Source Code

The source code of Gromacs can be downloaded from https://manual.gromacs.org/documentation/current/download.html. For simplicity, one can use the following commands to download the `2023.3` version:

~~~
$ wget https://ftp.gromacs.org/gromacs/gromacs-2023.3.tar.gz
$ tar zxvf https://ftp.gromacs.org/gromacs/gromacs-2023.3.tar.gz
$ cd gromacs-2023.3
~~~

- Create build directory

~~~
$ mkdir build_slurm
$ cd build_slurm
~~~

- Load available modules on Palmetto

~~~
module load openmpi/4.1.5 anaconda3/2022.10 intel-oneapi-mkl/2022.2.1
module use /software/ModuleFiles/modules/linux-rocky8-x86_64/
module load gcc/9.5.0 ## only need gcc-9.5 from old modules
~~~


- Identify architecture type and SIMD:

This is because Gromacs depends greatly on the architechture of the hardware as mentioend at the beginning. 

```
$ lscpu | grep "Model name"
```

Select the correct architecture based on the CPU model and corresponding SIMD:

- E5-2665: sandybridge (AVX_256)
- E5-2680: sandybridge (AVX_256)
- E5-2670v2: ivybridge (AVX_256)
- E5-2680v3: haswell (AVX2_256)
- E5-2680v4: broadwell (AVX2_256)
- 6148G: skylake (AVX_512)
- 6252G: cascadelake (AVX_512)
- 6238R: cascadelake (AVX_512)
- 6248: cascadelake (AVX_512)
- 8358: icelake (AVX_512)

In this example, given the previous `salloc` command, we most likely will get a node with `AVX_512`, which will be the input value for the below `-DGMX_SIMD`.

- Compiling Gromacs

~~~
$ cmake .. -DGMX_MPI=on -DGMX_GPU=CUDA -DGMX_FFT_LIBRARY=mkl -DGMX_SIMD=AVX_512 -DCMAKE_INSTALL_PREFIX=/home/$USER/software/gromacs-2023.3/build_slurm/gmx
$ make -j 20
$ make install -j 20
~~~

- Activate Gromacs Environment Variables

Once the installation/compilation finished, we can set the Gromacs environment variables by the following command, which is also very useful for interactive and batch jobs.

~~~
source /home/$USER/software/gromacs-2023.3/build_slurm/gmx/GMXRC
~~~

### Running GROMACS interactively

As an example,
we'll consider running the GROMACS ADH benchmark as in the pre-built case above.

First, request an interactive job if you exited the compute node from the above installation step:

~~~
$ salloc --nodes=1 --ntasks-per-node=20 --cpus-per-task=1 --gpus-per-node=a100:1 --mem=20G --time=01:00:00
~~~

Similar to the pre-build section, we can do the following steps to run Gromacs interactively.

~~~
$ mkdir -p /scratch/$USER/gromacs_ADH_benchmark
$ cd /scratch/$USER/gromacs_ADH_benchmark
$ wget ftp://ftp.gromacs.org/pub/benchmarks/ADH_bench_systems.tar.gz
$ tar -xzf ADH_bench_systems.tar.gz
$ source /home/$USER/software/gromacs-2023.3/build_slurm/gmx/bin/GMXRC
$ export OMP_NUM_THREADS=10
$ module load intel-oneapi-mkl/2022.2.1 openmpi/4.1.5 anaconda3/2022.10
$ srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr
$ srun gmx_mpi mdrun -s em.tpr -deffnm job-output
~~~

After the last command above completes,
the `.edr` and `.log` files produced by GROMACS should be visible.
Typically, the next step is to copy these results to the
output directory, e.g. home directory.

### Running GROMACS in batch mode

The PBS batch script for submitting the above is assumed to be inside `/scratch/$USER/gromacs_ADH_benchmark`,
and this directory already contains the all the input files including `em.tpr` generated in the `Node Selection` section of this document, and the PBS script, named as `gmx_pbs_manual.sh`:

~~~
#!/bin/sh
#SBATCH --job-name=GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6
#SBATCH --gpus-per-node=a100:2
#SBATCH --mem=22G
#SBATCH --time=0:15:00

cd $SLURM_SUBMIT_DIR

source /home/$USER/software/gromacs-2023.3/build_slurm/gmx/bin/GMXRC
module load openmpi/4.1.5 intel-oneapi-mkl/2022.2.1 anaconda3/2022.10 

export OMP_NUM_THREADS=6

# get the total number of MPI processes
echo number of MPI processes is $SLURM_NTASKS

# generate binary input file
srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

srun gmx_mpi mdrun -s em.tpr -deffnm job-output
~~~

Then use the following command to submit the batch job:
~~~
sbatch gmx_slurm_manual.sh
~~~

After the job finished we can use the following command to find the walltime/efficiency of the job:
~~~
tail -n 6 job-output.log | head -n 4
~~~
And it returns:
~~~
               Core t (s)   Wall t (s)        (%)
       Time:      144.795       12.067     1199.9
                 (ns/day)    (hour/ns)
Performance:      143.209        0.168
~~~

Compared to the pre-built version, we can see a big increase in the performance on the same task using the same hardware.

