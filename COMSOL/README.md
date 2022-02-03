## COMSOL

COMSOL is an application for solving Multiphysics problems.
To see the available COMSOL modules on Palmetto:

~~~
$ module avail comsol

comsol/5.4    comsol/5.5    comsol/5.6 (D)
~~~

To see license usage of COMSOL-related packages,
you can use the `lmstat` command:

~~~
/software/USR_LOCAL/flexlm/lmstat -a -c /software/USR_LOCAL/flexlm/licenses/comsol.dat
~~~

### Graphical Interface

To run the COMSOL graphical interface,
you must [log-in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/),
and then ask for an interactive session:

~~~
$ qsub -I -X -l select=1:ncpus=8:mpiprocs=8:mem=6gb:interconnect=1g,walltime=00:15:00
~~~

Once logged-in to an interactive compute node,
to launch the interactive viewer,
you can use the `comsol` command to run COMSOL:

~~~
$ module add comsol/5.2
$ comsol -np 8 -tmpdir $TMPDIR
~~~

The `-np` option can be used to specify the number of
CPU cores to use.
Remember to **always** use `$TMPDIR` as
the working directory for COMSOL jobs.

### Batch Mode

To run COMSOL in batch mode on Palmetto cluster,
you can use the example batch scripts below as a template.
The first example demonstrates running COMSOL using multiple cores
on a single node,
while the second demonstrates running COMSOL across multiple nodes
using MPI.
You can obtain the files required to run this example
using the following commands:

~~~
$ module add examples
$ example get COMSOL
$ cd COMSOL && ls

job.sh  job_mpi.sh
~~~

Both of these examples run the
"Heat Transfer by Free Convection" application described
[here](https://www.comsol.com/model/heat-transfer-by-free-convection-122).
In addition to the `job.sh` and `job_mpi.sh` scripts, to run the examples and reproduce the results,
you will need to download the file `free_convection.mph` (choose the correct version) provided
with the description (login required).

#### COMSOL batch job on a single node, using multiple cores:

~~~
#!/bin/bash
#PBS -N COMSOL
#PBS -l select=1:ncpus=8:mem=32gb,walltime=01:30:00
#PBS -j oe

module purge
module add comsol/5.5

cd $PBS_O_WORKDIR
mkdir -p /scratch1/$USER/tmp
SCRATCH=/scratch1/$USER/tmp

comsol batch -np 8 -tmpdir $SCRATCH -inputfile free_convection.mph -outputfile free_convection_output.mph
~~~

#### COMSOL batch job across several nodes.
Comsol by default uses its own intel mpi. However, the default intel mpi is not compatible with Palmetto's OS. Therefore, you need to force Comsol to use intel mpi installed in Palmetto:

~~~
#!/bin/bash
#PBS -N COMSOL
#PBS -l select=2:ncpus=8:mpiprocs=8:mem=32gb:interconnect=hdr,walltime=01:30:00
#PBS -j oe

module purge
module add comsol/5.6 intelmpi/21.1.1

cd $PBS_O_WORKDIR

comsol batch -nn 2 -np 8 -clustersimple -mpi intel -mpiroot $I_MPI_ROOT -tmpdir $TMPDIR -inputfile free_convection.mph -outputfile free_convection_output.mph
~~~
