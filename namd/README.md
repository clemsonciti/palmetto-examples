## NAMD

NAMD is a molecular dynamics simulation software written in charm++. Currently namd/2.14 is available on the palmetto cluster.
The user guide for NAMD/2.14 can be found here: https://www.ks.uiuc.edu/Research/namd/2.14/ug/. We noticed some newer versions for NAMD is available. If you need help installation of the latest version, please contact the RCDE team. More examples and tutorials for NAMD simulation can be found at [NAMD official website]( https://www.ks.uiuc.edu/Research/namd/)

~~~
$ module avail namd

namd/2.14
~~~

Note this is currently only available for PBS queues. Installation of NAMD is to be conducted. The current SLURM script is based on the NAMD installed in a local home directory using spack command `spack install namd@2.1.4 ^openmpi@4.1.5 ^cuda@11.7.0`, where the source code tarball needs to be downloaded manually.

The example input files are located in this repo and also /project/rcde/fanchem/NAMD on Palmetto cluster. You can get the input files first.
~~~
$ mkdir /scratch/$USER/namd_tutorial
$ cd /scratch/$USER/namd_tutorial
$ cp /project/rcde/fanchem/NAMD/al* .
~~~

Description for the input files:

- alanin is the NAMD configurtion file
- alanin.psf describes molecular structure,
- alanin.pbd describes the initial coordinates of the structure
- alanin.params  contains NAMD parameters.

It's best practice to  run NAMD in batch mode on Palmetto cluster, you can find the job scripts designed for this example in the following for different queues (PBS or SLURM) and accelerators (MPI or GPU) on Palmetto cluster.

### namd_gpu.pbs (PBS-GPU)

This example shows how to run NAMD in parallel with GPU accelerators on PBS queue.

~~~
#PBS -N namd_test
#PBS -l select=2:ncpus=10:mem=10gb:mpiprocs=1:interconnect=fdr:ngpus=1:gpu_model=any
#PBS -l walltime=1:00:00,place=scatter
#PBS -j oe

module load namd/2.14

cd $PBS_O_WORKDIR
mpirun -np 2 namd2 +ppn 10 +setcpuaffinity +idlepoll alanin > alanin.output
~~~

In general, the +ppn setting is the number of CPUs. We recommend `ngpus` set to 1, which means use only 1 GPU card per node. According to our test, more gpus per node will leave other gpus idle. The RCDE team is still tesing on this point. 

You can submit this script by `qsub namd_gpu.pbs`.

### namd_mpi.pbs (PBS-MPI)

Although users are encouraged to use GPU as accelerators to gain better performance, for light-duty jobs like minimization, users can also use the pure CPU versions.

~~~
#PBS -N namd_test
#PBS -l select=2:ncpus=10:mem=10gb:mpiprocs=1:interconnect=fdr
#PBS -l walltime=1:00:00,place=scatter
#PBS -j oe

module load namd/2.14.nocuda

cd $PBS_O_WORKDIR
mpirun -np 2 namd2 +ppn 10 +setcpuaffinity +idlepoll alanin > alanin.output
~~~

### namd_gpu.slurm (SLURM-GPU)

~~~
#!/bin/bash
#SBATCH --job-name=namd_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=10GB
#SBATCH --time=1:00:00
#SBATCH --gpus-per-node=a100:1

#module load namd/2.14 (place holder)
source ~/software_slurm_spack/spack/share/spack/setup-env.sh
spack load namd@2.14

cd $SLURM_SUBMIT_DIR

srun namd2 +ppn 10 +setcpuaffinity +idlepoll alanin > alanin.output
~~~

### namd_mpi.slurm (SLURM-MPI)

~~~
#!/bin/bash
#SBATCH --job-name=namd_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=10GB
#SBATCH --time=1:00:00

#module load namd/2.14 (place holder)
source ~/software_slurm_spack/spack/share/spack/setup-env.sh
spack load namd@2.14

cd $SLURM_SUBMIT_DIR

srun namd2 +ppn 10 +setcpuaffinity +idlepoll alanin > alanin.output
~~~ 
