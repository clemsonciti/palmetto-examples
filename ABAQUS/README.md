## ABAQUS

ABAQUS is a Finite Element Analysis software used
for engineering simulations.
Currently, ABAQUS versions 6.14, 2018, 2020, and 2021 are available on Palmetto cluster
as modules.

~~~
$ module avail abaqus

abaqus/6.14 abaqus/2018 abaqus/2020 abaqus/2021
~~~

To see license usage of ABAQUS-related packages,
you can use the `lmstat` command:

~~~
/software/USR_LOCAL/flexlm/lmstat -a -c /software/USR_LOCAL/flexlm/licenses/abaqus.dat
~~~


### Running ABAQUS interactive viewer

To run the interactive viewer,
you must [log in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/),
and then ask for an interactive session:

~~~
$ qsub -I -X -l select=1:ncpus=8:mpiprocs=8:mem=6gb:interconnect=1g,walltime=00:15:00
~~~

Once logged-in to an interactive compute node,
to launch the interactive viewer,
load the `abaqus` module, and run the `abaqus` executable with the `viewer` and `-mesa` options:

~~~
$ module add abaqus/6.14
$ abaqus viewer -mesa
~~~

Similarly,
to launch the ABAQUS CAE graphical interface:

~~~
$ abaqus cae -mesa
~~~

### Running ABAQUS in batch mode

To run ABAQUS in batch mode on Palmetto cluster,
you can use the job script in the following example as a template.
This example shows how to run ABAQUS in parallel using MPI.
This demonstration runs the "Axisymmetric analysis of bolted pipe flange connections"
example provided in the ABAQUS documentation [here](http://bobcat.nus.edu.sg:2080/v6.14/books/exa/default.htm).
Please see the documentation for the physics and simulation details.
You can obtain the files required to run this example
using the following commands:

~~~
$ cd /scratch1/username
$ module add examples
$ example get ABAQUS
$ cd ABAQUS && ls

abaqus_v6.env  boltpipeflange_axi_element.inp  boltpipeflange_axi_node.inp  boltpipeflange_axi_solidgask.inp  job.sh
~~~

The `.inp` files describe the model and simulation to be performed - see
the documentation for details.
The batch script `job.sh` submits the job to the cluster.
The `.env` file is a configuration file that **must** be included in all
ABAQUS job submission folders on Palmetto.

~~~
#!/bin/bash
#PBS -N AbaqusDemo
#PBS -l select=2:ncpus=8:mpiprocs=8:mem=6gb:interconnect=1g,walltime=00:15:00
#PBS -j oe

module purge
module add abaqus/6.14

pbsdsh sleep 20

NCORES=`wc -l $PBS_NODEFILE | gawk '{print $1}'`
cd $PBS_O_WORKDIR

SCRATCH=$TMPDIR

# copy all input files into the scratch directory
for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp $PBS_O_WORKDIR/*.inp $SCRATCH"
done

cd $SCRATCH

# run the abaqus program, providing the .inp file as input
abaqus job=abdemo double input=$SCRATCH/boltpipeflange_axi_solidgask.inp scratch=$SCRATCH cpus=$NCORES mp_mode=mpi interactive

# copy results back from scratch directory to $PBS_O_WORKDIR
for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
done
~~~

In the batch script `job.sh`:

1. The following line extracts the total number of CPU cores available across
   all the nodes requested by the job:

   ~~~
   NCORES=`wc -l $PBS_NODEFILE | gawk '{print $1}'`
   ~~~  

2. The following line runs the ABAQUS program, specifying various options
   such as the path to the `.inp` file, the scratch directory to use, etc.,

   ~~~
   abaqus job=abdemo double input=/scratch1/$USER/ABAQUS/boltpipeflange_axi_solidgask.inp scratch=$SCRATCH cpus=$NCORES mp_mode=mpi interactive
   ~~~  

To submit the job:

~~~
$ qsub job.sh
9668628
~~~

After job completion, you will see the job submission directory (`/scratch1/username/ABAQUS`)
populated with various files:

~~~
$ ls

AbaqusDemo.o9668628  abdemo.dat  abdemo.msg  abdemo.res  abdemo.stt                      boltpipeflange_axi_solidgask.inp
abaqus_v6.env        abdemo.fil  abdemo.odb  abdemo.sim  boltpipeflange_axi_element.inp  job.sh
abdemo.com           abdemo.mdl  abdemo.prt  abdemo.sta  boltpipeflange_axi_node.inp
~~~

If everything went well, the job output file (`AbaqusDemo.o9668628`) should look like this:

~~~
[atrikut@login001 ABAQUS]$ cat AbaqusDemo.o9668628
Abaqus JOB abdemo
Abaqus 6.14-1
Abaqus License Manager checked out the following licenses:
Abaqus/Standard checked out 16 tokens from Flexnet server licensevm4.clemson.edu.
<567 out of 602 licenses remain available>.
Begin Analysis Input File Processor
Mon 13 Feb 2017 12:35:29 PM EST
Run pre
Mon 13 Feb 2017 12:35:31 PM EST
End Analysis Input File Processor
Begin Abaqus/Standard Analysis
Mon 13 Feb 2017 12:35:31 PM EST
Run standard
Mon 13 Feb 2017 12:35:35 PM EST
End Abaqus/Standard Analysis
Abaqus JOB abdemo COMPLETED


+------------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES REQUESTED |
+------------------------------------------+

mem=12gb,ncpus=16,walltime=00:15:00


+-------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES USED |
+-------------------------------------+

cpupercent=90,cput=00:00:10,mem=636kb,ncpus=16,vmem=12612kb,walltime=00:00:13
~~~

The output database (`.odb`) file
contains the results of the simulation which can be viewed
using the ABAQUS viewer:

<img src="{{site.baseurl}}/images/abaqus-screenshot-results.png" style="width:650px">
