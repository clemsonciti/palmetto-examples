## COMSOL

COMSOL is an application for solving Multiphysics problems.
To see the available COMSOL modules on Palmetto:

~~~
$ module avail comsol

comsol/6.2
~~~

To see license usage of COMSOL-related packages,
you can use the `lmstat` command:

~~~
/hpc/flexlm/lmstat -a -c /hpc/flexlm/licenses/comsol.dat
~~~

### Graphical Interface

To run the COMSOL graphical interface,
you must [log-in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/),
and then ask for an interactive session:

~~~
$ salloc --nodes 1 --ntasks 8 --cpus-per-task 1 --mem 6gb --time 00:15:00
~~~

Once logged-in to an interactive compute node,
to launch the interactive viewer,
you can use the `comsol` command to run COMSOL:

~~~
$ module add comsol/6.2
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
#SBATCH --job-name COMSOL
#SBATCH --nodes 1
#SBATCH --ntasks 8
#SBATCH --cpus-per-task 1 
#SBATCH --mem 32gb
#SBATCH --time 01:30:00

module purge
module load comsol/6.2

cd $SLURM_SUBMIT_DIR
SCRATCH=$TMPDIR

comsol batch -np8 -tmpdir/$SCRATCH -inputfile free_convection.mph -outputfile free_convection_output.mph
~~~

#### COMSOL batch job across several nodes.
Comsol by default uses its own intel mpi. However, the default intel mpi is not compatible with Palmetto's OS. Therefore, you need to force Comsol to use intel mpi installed in Palmetto:

~~~
#!/bin/bash
#SBATCH --job-name COMSOL
#SBATCH --nodes 2
#SBATCH --ntasks 8
#SBATCH --cpus-per-task 1
#SBATCH --mem 32gb
#SBATCH --time 01:30:00

module purge
module add comsol/6.2 intel-oneapi-mpi/2021.11.0

cd $SLURM_SUBMIT_DIR

comsol batch -mpiboostrap slurm -clustersimple -mpi intel -mpiroot $I_MPI_ROOT -tmpdir $TMPDIR -inputfile free_convection.mph -outputfile free_convection_output.mph
~~~
