## ABAQUS

ABAQUS is a Finite Element Analysis software used
for engineering simulations.
Currently, ABAQUS versions 6.14, 2021, 2022 and 2023 are available on Palmetto cluster
as modules.

NOTICE: Abaqus cannot run on multiple nodes on Palmetto. The RCDE team is still work on this issue.
~~~
$ module avail abaqus

------------------------------------------------------------------------- /software/AltModFiles --------------------------------------------------------------------------
   abaqus/6.14    abaqus/2021    abaqus/2022    abaqus/2023 (D)
~~~

To see license usage of ABAQUS-related packages,
you can use the `lmstat` command:

~~~
/hpc/flexlm/lmstat -a -c /hpc/flexlm/licenses/abaqus.dat
~~~

### Running ABAQUS in batch mode

We have provided four job scripts in this repo for different schedulers (PBS and SLURM) and different accelerators (CPU and GPU).
To run ABAQUS in batch mode on Palmetto cluster, you can use the one of the job scripts as a template.
This repo also consists of the "Axisymmetric analysis of bolted pipe flange connections"
example provided in the ABAQUS documentation [here](http://bobcat.nus.edu.sg:2080/v6.14/books/exa/default.htm).
Please see the documentation for the physics and simulation details.
You can obtain the files required to run this example
using the following commands:

~~~
$ cd /scratch/$USER
$ git clone git@github.com:clemsonciti/palmetto-examples.git
$ cd palmetto-examples/ABAQUS
$ ls

abaqus_cpu.pbs    abaqus_gpu.pbs    abaqus-screenshot-results.png   boltpipeflange_axi_node.inp       README.md
abaqus_cpu.slurm  abaqus_gpu.slurm  boltpipeflange_axi_element.inp  boltpipeflange_axi_solidgask.inp  
~~~

The `.inp` files describe the model and simulation to be performed - see
the documentation for details.
The batch script `abaqus_cpu.pbs`, `abaqus_gpu.pbs`, `abaqus_cpu.slurm` and `abaqus_gpu.slrum` submits the job to the cluster with different accelerator and for different scheduler.

To submit the job using CPU only and using PBS scheduler:

~~~
$ qsub abaqus_cpu.pbs
~~~

After job completion, you will see the job submission directory (`/scratch/$USER/ABAQUS`)
populated with various files:

~~~
$ ls

abaqus_cpu.pbs    abaqus_gpu.slurm               abaqus_test.dat  abaqus_test.msg       abaqus_test.prt  abaqus_test.sta                 boltpipeflange_axi_node.inp
abaqus_cpu.slurm  abaqus-screenshot-results.png  abaqus_test.fil  abaqus_test.o1553750  abaqus_test.res  abaqus_test.stt                 boltpipeflange_axi_solidgask.inp
abaqus_gpu.pbs    abaqus_test.com                abaqus_test.mdl  abaqus_test.odb       abaqus_test.sim  boltpipeflange_axi_element.inp  README.md
~~~

If everything went well, the job output file (`abaqus_test.o1553750`) should look like this:

~~~
$ cat abaqus_test.o1553750
Analysis initiated from SIMULIA established products
Abaqus JOB abaqus_test
Abaqus 2023
Abaqus License Manager checked out the following licenses:
Abaqus/Standard checked out 13 tokens from Flexnet server license4.clemson.edu.
<444 out of 602 licenses remain available>.
Begin Analysis Input File Processor
Tue 14 Nov 2023 03:27:03 PM EST
Run pre
Tue 14 Nov 2023 03:27:07 PM EST
End Analysis Input File Processor
Begin Abaqus/Standard Analysis
Tue 14 Nov 2023 03:27:07 PM EST
Run standard
Tue 14 Nov 2023 03:27:09 PM EST
End Abaqus/Standard Analysis
Begin SIM Wrap-up
Tue 14 Nov 2023 03:27:09 PM EST
Run SMASimUtility
Tue 14 Nov 2023 03:27:09 PM EST
End SIM Wrap-up
Abaqus JOB abaqus_test COMPLETED


+------------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES REQUESTED |
+------------------------------------------+

mem=12gb,walltime=02:00:00,ncpus=10


+-------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES USED |
+-------------------------------------+

cput=00:00:04,mem=527268kb,walltime=00:00:13,ncpus=10,cpupercent=0,vmem=4076156kb
~~~

The output database (`.odb`) file
contains the results of the simulation which can be viewed
using the ABAQUS viewer:

<img src="{{site.baseurl}}/abaqus-screenshot-results.png" style="width:650px">

### Running ABAQUS interactive viewer

To run the interactive viewer,
you must [log in with X11 tunneling enabled](https://docs.rcd.clemson.edu/palmetto/connect/x11_tunneling/?utm_source=old-site-redirect),
and then ask for an interactive session:

~~
$ qsub -I -X -l select=1:ncpus=8:mpiprocs=8:mem=6gb:interconnect=1g,walltime=00:15:00
~~

Once logged-in to an interactive compute node,
to launch the interactive viewer,
load the `abaqus` module, and run the `abaqus` executable with the `viewer` and `-mesa` options:

~~
$ module add abaqus/2023
$ abaqus viewer -mesa
~~

Similarly,
to launch the ABAQUS CAE graphical interface:

~~
$ abaqus cae -mesa
~~
