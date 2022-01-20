## NAMD

NAMD is a molecular dynamics simulation software written in charm++. Currently namd/2.14 is available on the palmetto cluster.
The user guide for NAMD/2.14 can be found here: https://www.ks.uiuc.edu/Research/namd/2.14/ug/

~~~
$ module avail namd

namd/2.14
~~~

### Running NAMD in Batch mode

To run NAMD in batch mode on Palmetto cluster,
you can use the job script in the following example as a template.
This example shows how to run NAMD in parallel.
More examples and tutorials for NAMD simulation can be found at: https://www.ks.uiuc.edu/Research/namd/

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
