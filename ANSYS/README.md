## ANSYS

| **NOTE**
| If you have any trouble with Ansys please reach out to us through our [email
| support](https://docs.rcd.clemson.edu/support/contact/email). We are not
| experts in Ansys and solving your problem may require a collaboration between
| the user (you) and us (the research facilitators/system administrators).
|
| If you have success in using Ansys, in particular medium sized runtimes (10
| minutes to an hour), we'd love to include your input and batch submission as a
| benchmark. This would allow us to detect regressions, both performance and when
| an upgrade breaks Ansys and allow us to solves these issues faster.
| If you'd like to help us in this regard, please reach out to us through our
| [email support](https://docs.rcd.clemson.edu/support/contact/email)

### Graphical Interfaces

Note: as a general rule of thumb, we don't encourage using Ansys graphically
extensively on Palmetto. Although Palmetto has GPUs, they are computational
only GPUs, they cannot be used to render images, meaning Palmetto is not setup
for large amounts of 3d modeling or displays. Instead, the suggested workflow
is to use your own personal computer or a lab computer to do the initial project
setup, then transfer to Palmetto for analysis. If you'd like help with your
workflow, feel free to join the RCDE team for [office
hours](https://docs.rcd.clemson.edu/support/contact/office_hours) or submit an
[IT Help ticket](https://docs.rcd.clemson.edu/support/contact/office_hours).

To run the various ANSYS graphical programs, We recommend you use the [Palmetto
Desktop](https://docs.rcd.clemson.edu/palmetto/connect/openod/apps/desktop)
through Open OnDemand. Alternatively, there are [other
ways](https://docs.rcd.clemson.edu/palmetto/software/graphical) of running
Ansys, including [X11
forwarding](https://docs.rcd.clemson.edu/palmetto/connect/x11_tunneling).

Request a Palmetto Desktop with the following:

- Resolution: 1920x1080 (or change to your preference)
- Number of resource chunks: 1
- CPU cores per chunk: 8
- Memory per chunk: 8gb
- No GPUs
- Interconnect: fdr
- Walltime: 04:00:00

Once you connect to the Palmetto Desktop (click the Launch Palmetto Desktop
after it finishes starting), bring up the Terminal Emulator within the desktop.
From there you will have to load the Ansys module. For example to run Ansys
22.2, use:

```sh
module load ansys/22.2
```

Note: the list of supported versions change. To check which versions are
available, use [`module
avail`](https://docs.rcd.clemson.edu/palmetto/software/modules):

```sh
module avail ansys
```

And then launch the required program:

**For ANSYS APDL**

```
ansys222 -g
```

Note: this program uses has the Ansys version in the executable name so if you
load a different version, you will have to change the name. For example Ansys
21.1 would use `ansys211`.

**For CFX**

```
cfxlaunch
```

**For ANSYS Workbench**

```
runwb2
```

**For Fluent**

```
fluent
```

**For ANSYS Electromagnetics** Note you have to ignore the OS check or it complains.

```
ANS_IGNOREOS=1 ansysedt
```

### Batch Mode

To run ANSYS in batch mode on Palmetto cluster,
you can use the job script in the following example as a template.
This example shows how to run ANSYS in parallel (using multiple cores/nodes).
In this demonstration, we model the strain in a 2-D flat plate.
You can obtain the files required to run this example
using the following commands:

```
mkdir -p /scratch/username/ANSYS-test
cd /scratch/username/ANSYS-test
curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/ANSYS/input.txt
curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/ANSYS/job.sh
```

The `input.txt` batch file is generated for the model using the Ansys APDL interface.
The batch script `job.sh` submits the batch job to the cluster:

```
#!/bin/bash
#PBS -N ANSYSdis
#PBS -l select=2:ncpus=4:mpiprocs=4:mem=11gb:interconnect=fdr
#PBS -l walltime=1:00:00
#PBS -j oe

set -e

# Uncomment the next line for bash trace mode (debugging).
#set -x

module purge
module add ansys/22.2

# This pbsdsh command will make sure that $TMPDIR is setup on each other node
pbsdsh sleep 5

cd "$PBS_O_WORKDIR"

machines=$(uniq -c "$PBS_NODEFILE" | awk '{print $2":"$1}' | tr '\n' :)
machines=${machines::-1}

SCRATCH=$TMPDIR/ansys-run

echo "Setting up scratch dirs..."
for node in $(uniq "$PBS_NODEFILE")
do
    ssh $node "rm -rf '$SCRATCH'"
    ssh $node "mkdir -p '$SCRATCH'"
    ssh $node "cp $PBS_O_WORKDIR/input.txt $SCRATCH"
done

cd "$SCRATCH"

# Create an SSH stub that unsets LD_LIBRARY_PATH. This is needed because Ansys
# adds a bunch of garbage to LD_LIBRARY_PATH that conflicts with the host ssh.
mkdir -p "$SCRATCH/bin"
cat << EOF > "$SCRATCH/bin/ssh"
#!/bin/bash
unset LD_LIBRARY_PATH
/bin/ssh "\$@"
EOF
chmod +x "$SCRATCH/bin/ssh"
OLD_PATH=$PATH
export PATH="$SCRATCH/bin:$PATH"


echo "Running Ansys, machines= $machines ..."
set +e
ansys222 \
    -mpi openmpi \
    -dir "$SCRATCH" \
    -j EXAMPLE \
    -s read -l en-us -b \
    -i input.txt -o output.txt \
    -dis -machines "$machines"
set -e

# Restore PATH (we're about to delete that ssh stub).
export PATH="$OLD_PATH"

echo "Ansys done, coping files"
for node in $(uniq "$PBS_NODEFILE")
do
    ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
    ssh $node "rm -rf $SCRATCH"
done
echo "Done!"
```

In the batch script `job.sh`:

1. The following line extracts the nodes (machines) available for this job
   as well as the number of CPU cores allocated for each node:

   ```
   machines=$(uniq -c "$PBS_NODEFILE" | awk '{print $2":"$1}' | tr '\n' :)
   machines=${machines::-1}
   ```

2. For Ansys jobs, you should always use `$TMPDIR` (`/local_scratch`) as the
   working directory. The following lines ensure that `$TMPDIR` is created on
   each node and the input is copied over to it.

   ```
   SCRATCH=$TMPDIR/ansys-run
   for node in $(uniq "$PBS_NODEFILE")
   do
        ssh $node "mkdir -p $SCRATCH"
        ssh $node "cp $PBS_O_WORKDIR/input.txt $SCRATCH"
   done
   ```

3. The following line runs the Ansys program, specifying various options
   such as the path to the `input.txt` file, the scratch directory to use, etc.,

   ```
    ansys222 \
        -mpi openmpi \
        -dir "$SCRATCH" \
        -j EXAMPLE \
        -s read -l en-us -b \
        -i input.txt -o output.txt \
        -dis -machines "$machines"
   ```

4. Finally, the following lines copy all the data
   from `$TMPDIR`:

   ```
    for node in $(uniq "$PBS_NODEFILE")
    do
        ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
        ssh $node "rm -rf $SCRATCH"
    done
   ```

To submit the job:

```
qsub job.sh
9752784
```

After job completion, you will see the job submission directory (`/scratch/username/ANSYS-test`)
populated with various files:

```
$ ls

ANSYSdis.o9752784  EXAMPLE0.stat  EXAMPLE2.err   EXAMPLE3.esav  EXAMPLE4.full  EXAMPLE5.out   EXAMPLE6.rst   EXAMPLE.DSP    input.txt
EXAMPLE0.err       EXAMPLE1.err   EXAMPLE2.esav  EXAMPLE3.full  EXAMPLE4.out   EXAMPLE5.rst   EXAMPLE7.err   EXAMPLE.esav   job.sh
EXAMPLE0.esav      EXAMPLE1.esav  EXAMPLE2.full  EXAMPLE3.out   EXAMPLE4.rst   EXAMPLE6.err   EXAMPLE7.esav  EXAMPLE.mntr   mpd.hosts
EXAMPLE0.full      EXAMPLE1.full  EXAMPLE2.out   EXAMPLE3.rst   EXAMPLE5.err   EXAMPLE6.esav  EXAMPLE7.full  EXAMPLE.rst    mpd.hosts.bak
EXAMPLE0.log       EXAMPLE1.out   EXAMPLE2.rst   EXAMPLE4.err   EXAMPLE5.esav  EXAMPLE6.full  EXAMPLE7.out   host.list      output.txt
EXAMPLE0.rst       EXAMPLE1.rst   EXAMPLE3.err   EXAMPLE4.esav  EXAMPLE5.full  EXAMPLE6.out   EXAMPLE7.rst   host.list.bak
```

If everything went well, the job output file (`ANSYSdis.o9752784`) should look like this:

```
Setting up scratch dirs...
Running Ansys, machines= node1637.palmetto.clemson.edu:4:node1647.palmetto.clemson.edu:4 ...
<snip ... some warnings might be present ... snip>
Ansys done, coping files
Done!
+------------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES REQUESTED |
+------------------------------------------+

mem=22gb,ncpus=8,walltime=01:00:00


+-------------------------------------+
| PALMETTO CLUSTER PBS RESOURCES USED |
+-------------------------------------+

cpupercent=27,cput=00:00:17,mem=3964kb,ncpus=8,vmem=327820kb,walltime=00:01:07
```

The results file (`EXAMPLE.rst`) contains the results of the simulation.
