## ANSYS

> **NOTE**
> If you have any trouble with Ansys please reach out to us through our [email
> support](https://docs.rcd.clemson.edu/support/contact/email). We are not
> experts in Ansys and solving your problem may require a collaboration between
> the user (you) and us (the research facilitators/system administrators).
>
> If you have success in using Ansys, in particular medium sized runtimes (10
> minutes to an hour), we'd love to include your input and batch submission as a
> benchmark. This would allow us to detect regressions, both performance and
> when an upgrade breaks Ansys. Detecting these issues earlier (we'd run the
> benchmarks before and after each maintenance) would allow us to solves these
> issues faster. If you'd like to help us in this regard, please reach out to us
> through our [email support](https://docs.rcd.clemson.edu/support/contact/email)

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
23.2, use:

```sh
module load ansys/23.2
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
ansys232 -g
```

Note: this program uses has the Ansys version in the executable name so if you
load a different version, you will have to change the name. For example Ansys
22.2 would use `ansys222`.

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
mkdir -p /scratch/$USER/ANSYS-test
cd /scratch/$USER/ANSYS-test
curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/ANSYS/SLURM/input.txt
curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/ANSYS/SLURM/job.sh
```

The `input.txt` batch file is generated for the model using the Ansys APDL interface.
The batch script `job.sh` submits the batch job to the cluster:

```
#!/bin/bash
#SBATCH --job-name=ansys
#SBATCH --nodes=1
#SBATCH --tasks-per-node=12
#SBATCH --mem=24G
#SBATCH --constraint=extension_avx512
#SBATCH --time=1:0:0

module purge
module load ansys

cd $SLURM_SUBMIT_DIR

SCRATCH=$SLURM_SUBMIT_DIR

rm host.list*
rm HOSTNAME

srun hostname > HOSTNAME
machines=$(uniq -c HOSTNAME | awk '{print $2":"$1}' | tr '\n' :)
machines=${machines::-1}

ansys232 \
    -mpi openmpi \
    -dir "$SCRATCH" \
    -j EXAMPLE \
    -s read -l en-us -b \
    -i input.txt -o output.txt \
    -dis -machines "$machines"
```

In the batch script `job.sh`:

1. The following line extracts the nodes (machines) available for this job
   as well as the number of CPU cores allocated for each node:

   ```
   srun hostname > HOSTNAME
   machines=$(uniq -c HOSTNAME | awk '{print $2":"$1}' | tr '\n' :)
   machines=${machines::-1}
   ```

2. The following line runs the Ansys program, specifying various options
   such as the path to the `input.txt` file, the scratch directory to use, etc.,

   ```
    ansys232 \
        -mpi openmpi \
        -dir "$SCRATCH" \
        -j EXAMPLE \
        -s read -l en-us -b \
        -i input.txt -o output.txt \
        -dis -machines "$machines"
   ```
To submit the job:

```
sbatch job.sh
```

After job completion, you will see the job submission directory (`/scratch/$USER/ANSYS-test`)
populated with various files:

```
$ ls

EXAMPLE0.err   EXAMPLE1.esav  EXAMPLE2.out   EXAMPLE.DSP   output.txt
EXAMPLE0.esav  EXAMPLE1.full  EXAMPLE2.rst   EXAMPLE.esav  slurm-1231122.out
EXAMPLE0.full  EXAMPLE1.out   EXAMPLE3.err   EXAMPLE.mntr  sub.sh
EXAMPLE0.log   EXAMPLE1.rst   EXAMPLE3.esav  EXAMPLE.rst
EXAMPLE0.rst   EXAMPLE2.err   EXAMPLE3.full  host.list
EXAMPLE0.stat  EXAMPLE2.esav  EXAMPLE3.out   HOSTNAME
EXAMPLE1.err   EXAMPLE2.full  EXAMPLE3.rst   input.txt
```

The results file (`EXAMPLE.rst`) contains the results of the simulation.
