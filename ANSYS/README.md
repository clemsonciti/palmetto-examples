## ANSYS

### Graphical Interfaces

To run the various ANSYS graphical programs,
you must [log-in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/)
and then ask for an interactive session:

~~~
$ qsub -I -X -l select=1:ncpus=8:mpiprocs=8:mem=6gb:interconnect=fdr,walltime=01:00:00
~~~

Once logged-in to an interactive compute node,
you must first load the ANSYS module along with the Intel module:

~~~
$ module add ansys/19.5

~~~

And then launch the required program:

**For ANSYS APDL**

~~~
$ ansys195 -g
~~~

If you are using e.g., ANSYS 20.2 instead, then the executable is called `ansys202`.

**For CFX**

~~~
$ cfxlaunch
~~~

**For ANSYS Workbench**

~~~
$ runwb2
~~~

**For Fluent**

~~~
$ fluent
~~~

**For ANSYS Electromagnetics** (only available for ansys/20.2+). Note you have to ignore the OS check or it complains.

~~~
$ ANS_IGNOREOS=1 ansysedt
~~~

### Batch Mode

To run ANSYS in batch mode on Palmetto cluster,
you can use the job script in the following example as a template.
This example shows how to run ANSYS in parallel (using multiple cores/nodes).
In this demonstration, we model the strain in a 2-D flat plate.
You can obtain the files required to run this example
using the following commands:

~~~
$ cd /scratch1/username
$ module add examples
$ example get ANSYS
$ cd ANSYS && ls

input.txt job.sh
~~~

The `input.txt` batch file is generated for the model using the ANSYS APDL interface.
The batch script `job.sh` submits the batch job to the cluster:

~~~
#!/bin/bash
#PBS -N ANSYSdis
#PBS -l select=2:ncpus=4:mpiprocs=4:mem=11gb:interconnect=1g
#PBS -l walltime=1:00:00
#PBS -j oe

module purge
module add ansys/19.5

cd $PBS_O_WORKDIR

machines=$(uniq -c $PBS_NODEFILE | awk '{print $2":"$1}' | tr '\n' :)

for node in `uniq $PBS_NODEFILE`
do
    ssh $node "sleep 5"
    ssh $node "cp input.txt $TMPDIR"
done

cd $TMPDIR
ansys195 -dir $TMPDIR -j EXAMPLE -s read -l en-us -b -i input.txt -o output.txt -dis -machines $machines -usessh

for node in `uniq $PBS_NODEFILE`
do
    ssh $node "cp -r $TMPDIR/* $PBS_O_WORKDIR"
done
~~~

In the batch script `job.sh`:

1. The following line extracts the nodes (machines) available for this job
   as well as the number of CPU cores allocated for each node:

   ~~~
   machines=$(uniq -c $PBS_NODEFILE | awk '{print $2":"$1}' | tr '\n' :)
   ~~~  

2. For ANSYS jobs, you should always use `$TMPDIR` (`/local_scratch`) as the working directory.
   The following lines ensure that `$TMPDIR` is created on each node:

   ~~~
   do
       ssh $node "sleep 5"
       ssh $node "cp input.txt $TMPDIR"
   done
   ~~~  

3. The following line runs the ANSYS program, specifying various options
   such as the path to the `input.txt` file, the scratch directory to use, etc.,

   ~~~
   ansys195 -dir $TMPDIR -j EXAMPLE -s read -l en-us -b -i input.txt -o output.txt -dis -machines $machines -usessh
   ~~~  

4. Finally, the following lines copy all the data
   from `$TMPDIR`:

   ~~~
	do
		ssh $node "cp -r $TMPDIR/* $PBS_O_WORKDIR"
	done
   ~~~

To submit the job:

~~~
$ qsub job.sh
9752784
~~~

After job completion, you will see the job submission directory (`/scratch2/username/ANSYS`)
populated with various files:

~~~
$ ls

ANSYSdis.o9752784  EXAMPLE0.stat  EXAMPLE2.err   EXAMPLE3.esav  EXAMPLE4.full  EXAMPLE5.out   EXAMPLE6.rst   EXAMPLE.DSP    input.txt
EXAMPLE0.err       EXAMPLE1.err   EXAMPLE2.esav  EXAMPLE3.full  EXAMPLE4.out   EXAMPLE5.rst   EXAMPLE7.err   EXAMPLE.esav   job.sh
EXAMPLE0.esav      EXAMPLE1.esav  EXAMPLE2.full  EXAMPLE3.out   EXAMPLE4.rst   EXAMPLE6.err   EXAMPLE7.esav  EXAMPLE.mntr   mpd.hosts
EXAMPLE0.full      EXAMPLE1.full  EXAMPLE2.out   EXAMPLE3.rst   EXAMPLE5.err   EXAMPLE6.esav  EXAMPLE7.full  EXAMPLE.rst    mpd.hosts.bak
EXAMPLE0.log       EXAMPLE1.out   EXAMPLE2.rst   EXAMPLE4.err   EXAMPLE5.esav  EXAMPLE6.full  EXAMPLE7.out   host.list      output.txt
EXAMPLE0.rst       EXAMPLE1.rst   EXAMPLE3.err   EXAMPLE4.esav  EXAMPLE5.full  EXAMPLE6.out   EXAMPLE7.rst   host.list.bak
~~~

If everything went well, the job output file (`ANSYSdis.o9752784`) should look like this:

~~~
+------------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES REQUESTED |
+------------------------------------------+

mem=22gb,ncpus=8,walltime=01:00:00


+-------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES USED |
+-------------------------------------+

cpupercent=27,cput=00:00:17,mem=3964kb,ncpus=8,vmem=327820kb,walltime=00:01:07
~~~

The results file (`EXAMPLE.rst`)
contains the results of the simulation which can be viewed
using the ANSYS APDL graphical interface:

<img src="{{site.baseurl}}/images/ansys-screenshot-results.png" style="width:650px">
