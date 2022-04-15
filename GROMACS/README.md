# GROMACS

- Gromacs is an architecture-specific software. It performs best when installed and configured on the
  specific hardware.

## Using pre-built versions of GROMACS

Palmetto comes with GROMACS pre installed as a module, these can be found with the module command

```
$ module avail gromacs
```

We recommend you use `gromacs/2020.4-gcc/8.4.1-mpi-openmp-cuda11_4` as it should work immediately with the test files. There are other modules available for different use cases.

### Node Selection

We recommend that you select a node that has a GPU to utilize the extra performance gained from using one. An example node could look something like this

```
$ qsub -I -l select=1:ncpus=6:mem=26gb:ngpus=1:gpu_model=v100:interconnect=hdr,walltime=00:20:00
```

Next we can load in our pre-built version of GROMACS from the module list

```
$ module load gromacs/2020.4-gcc/8.4.1-mpi-openmp-cuda11_4
```

If you have your own input settings you should compile them into an input file.

If you don't have an input file you can create one from the GROMACS benchmarks.

```
$ wget ftp://ftp.gromacs.org/pub/benchmarks/ADH_bench_systems.tar.gz
$ tar -xvf ADH_bench_system.tar.gz
$ cd ADH/adh_cubic
$ gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr
```

You can then run your input file with `gmx_mpi`

```
$ gmx_mpi mdrun -s em.tpr -deffnm job_output
```

## Running in batch mode

In an ideal scenario you will be running GROMACS in a batch script which will let you utilize openMPI for faster performance.

An example of a batch script where em.tpr is in the same directory as the script.

```
#PBS -N GROMACS
#PBS -l select=4:ncpus=12:mpiprocs=2:ngpus=2:gpu_model=v100:interconnect=hdr:mem=22gb
#PBS -j oe
#PBS -l walltime=0:15:00

module purge
module load gromacs/2020.4-gcc/8.4.1-mpi-openmp-cuda11_4
module load openmpi/3.1.6-gcc/8.3.1-cuda10_2-ucx


# Gromacs recommends having between 2 and 6 threads;
export OMP_NUM_THREADS=6

cd $PBS_O_WORKDIR

# get the total number of MPI processes
N_MPI_PROCESSES=`cat $PBS_NODEFILE | wc -l`
echo number of MPI processes is $N_MPI_PROCESSES

mpirun -np $N_MPI_PROCESSES -npernode 2 gmx_mpi mdrun -s em.tpr -deffnm job-output

```

Note that `ncpus` should be the product of `OMP_NUM_THREADS` and `npernode`.
You can also select more or less nodes with the `select` option when requesting resources.

More information on GROMACS performance optimisation can be found [here.](https://manual.gromacs.org/documentation/current/user-guide/mdrun-performance.html)

## Manually Installing GROMACS

- To simplify the process of setting up gromacs, we recommend that you set up your local spack
  using [instructions from the following links](https://www.palmetto.clemson.edu/palmetto/software/spack/).

- Get a node (choose the node type you wish to run Gromacs on)

```
$ qsub -I -l select=1:ncpus=20:mem=20gb:ngpus=1:gpu_model=p100:interconnect=10ge,walltime=5:00:00
```

- Identify architecture type:

```
$ lscpu | grep "Model name"
```

Select the crrect architecture based on the CPU model:

- E5-2665: sandybridge
- E5-2680: sandybridge
- E5-2670v2: ivybridge
- E5-2680v3: haswell
- E5-2680v4: broadwell
- 6148G: skylake
- 6252G: cascadelake
- 6238R: cascadelake

In this example, given the previous `qsub` command, we most likely will get a broadwell node:

```
$ export TARGET=broadwell
```

### Installing cuda

```
$ spack spec -Il cuda@10.2.89 target=$TARGET
$ spack install cuda@10.2.89 target=$TARGET
$ spack find -ld cuda@10.2.89
```

You should remember the hash value of the cuda installation for later use.

### Installing fftw

```
spack spec -Il fftw@3.3.8~mpi+openmp target=$TARGET
spack install fftw@3.3.8~mpi+openmp target=$TARGET
```

### Installing gromacs

```
$ export MODULEPATH=$MODULEPATH:~/software/ModuleFiles/modules/linux-centos8-broadwell/
$ module load fftw-3.3.8-gcc-8.3.1-openmp cuda-10.2.89-gcc-8.3.1
$ spack spec -Il gromacs@2018.3+cuda~mpi target=$TARGET ^cuda/hash_value_you_memorize_earlier
$ spack install gromacs@2018.3+cuda~mpi target=$TARGET ^cuda/hash_value_you_memorize_earlier
```

Gromacs will now be available in your local module path

### Running GROMACS interactively

As an example,
we'll consider running the GROMACS ADH benchmark.

First, request an interactive job:

```
$ qsub -I -l select=1:ncpus=20:mem=100gb:ngpus=2:gpu_model=p100:interconnect=10ge,walltime=5:00:00
$ mkdir -p /scratch1/$USER/gromacs_ADH_benchmark
$ cd /scratch1/$USER/gromacs_ADH_benchmark
$ wget ftp://ftp.gromacs.org/pub/benchmarks/ADH_bench_systems.tar.gz
$ tar -xzf ADH_bench_systems.tar.gz
$ export MODULEPATH=$MODULEPATH:~/software/ModuleFiles/modules/linux-centos8-broadwell/
$ export OMP_NUM_THREADS=10
$ module load fftw-3.3.8-gcc-8.3.1-openmp cuda-10.2.89-gcc-8.3.1 gromacs-2018.3-gcc-8.3.1-cuda10_2-openmp
$ gmx mdrun -g adh_cubic.log -pin on -resethway -v -noconfout -nsteps 10000 -s topol.tpr -ntmpi 2 -ntomp 10
```

After the last command above completes,
the `.edr` and `.log` files produced by GROMACS should be visible.
Typically, the next step is to copy these results to the
output directory:

### Running GROMACS in batch mode

The PBS batch script for submitting the above is assumed to be inside `/scratch1/$USER/gromacs_ADH_benchmark`,
and this directory already contains the input files:

```
#PBS -N adh_cubic
#PBS -l select=1:ngpus=2:ncpus=16:mem=20gb:gpu_model=p100:interconnect=10ge,walltime=5:00:00

cd $PBS_O_WORKDIR

export MODULEPATH=$MODULEPATH:~/software/ModuleFiles/modules/linux-centos8-broadwell/
module load fftw-3.3.8-gcc-8.3.1-openmp cuda-10.2.89-gcc-8.3.1 gromacs-2018.3-gcc-8.3.1-cuda10_2-openmp
gmx mdrun -g adh_cubic.log -pin on -resethway -v -noconfout -nsteps 10000 -s topol.tpr -ntmpi 2 -ntomp 10
```
