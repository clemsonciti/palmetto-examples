## NAMD

NAMD is a molecular dynamics simulation software written in charm++. Currently namd/2.14 is available on the palmetto cluster.
The user guide for NAMD/2.14 can be found here: https://www.ks.uiuc.edu/Research/namd/2.14/ug/. We noticed some newer versions for NAMD is available. If you need help installation of the latest version, please contact the RCDE team.

~~~
$ module avail namd

namd/2.14
~~~

Note this is currently only available for PBS queues. Installation of NAMD is to be conducted. The current SLURM script is based on the NAMD installed in a local home directory.

The example input files are located in this repo and also /project/rcde/fanchem/NAMD on Palmetto cluster. You can get the input files first.
~~~
$ mkdir /scratch/$USER/namd_tutorial
$ cd /scratch/$USER/namd_tutorial
$ cp /project/rcde/fanchem/NAMD/al* .
~~~

### Running NAMD in Batch mode (PBS-GPU)

To run NAMD in batch mode on Palmetto cluster,
you can use the job script in the following example as a template.
This example shows how to run NAMD in parallel with GPU accelerators.
More examples and tutorials for NAMD simulation can be found at [NAMD official website]( https://www.ks.uiuc.edu/Research/namd/)

The example input files are l

You can obtain the files required to run this example
using the following commands:

~~~
$ cd /scratch1/username
$ module add examples
$ example get NAMD
$ cd NAMD && ls

alanin alanin.params alanin.pdb alanin.psf job.sh README.md
~~~
alanin is the NAMD configurtion file, alanin.psf describes molecular structure, 
alanin.pbd describes the initial coordinates of the structure,and alanin.params  contains NAMD parameters.
Job.sh is the batch script that submits the job to the queue. All five input files are required to run the simulation.

~~~
#!/bin/bash

#PBS -N NAMD-Example
#PBS -l select=2:ncpus=2:mem=10gb:interconnect=any:ngpus=1:gpu_model=any
#PBS -l walltime=2:00:00
#PBS -j oe

module load namd/2.14

cd $PBS_O_WORKDIR
mpirun namd2 +ppn 1 alanin > alanin.output

~~~

*Note: in the line 'mpirun namd2 +ppn 1 alanin > alanin.output' the number following the command '+ppn'  must be one less than the number of cpus requested.
