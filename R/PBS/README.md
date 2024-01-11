# R

In addition to running an interactive R Studio session through [Open
OnDemand](https://docs.rcd.clemson.edu/openod/apps/r_studio_server/), you can also run
them as [batch compute
jobs](https://docs.rcd.clemson.edu/palmetto/jobs/submit/#submit-a-batch-job).
With a batch compute job, you no longer have the resource restrictions from
interactive Open OnDemand jobs.

To create a batch job, you will need a batch script that contains the
appropriate PBS options and loads the appropriate modules and environments.

In this example, we will use

- R: `r/4.2.0-gcc/9.5.0` (for complete list of version, use `module avail r/`),
- R script file directory: $HOME/r_test
- R script file: test.r
- 1 node,
- 4gb memory per node,
- 2 cores per node, and
- 10 minutes.

Replace the above values as needed in the instructions below. You can also add
specialized resource requests (e.g. GPUs). See the [PBS job options
documentation](https://docs.rcd.clemson.edu/palmetto/jobs/submit/#resource-limits-specification)
for details.

Create a file `$HOME/r_test/submit.pbs` with the following content:

```sh
#!/bin/bash
#PBS -N r-test
#PBS -l select=1:ncpus=2:mem=4gb
#PBS -l walltime=00:10:00
#PBS -j oe

set -e

module load r/4.2.0-gcc/9.5.0

cd $HOME/r_test
Rscript test.r
```

Once your script is created, you can submit it by connecting to the [login
node](https://docs.rcd.clemson.edu/palmetto/connect/ssh/) and running:

```
cd r_test
qsub submit.pbs
```

You can check status of queued and running job status with:

```
qstat -u <username>
```

or running and completed jobs with:

```
qstat -xu <username>
```

Once the job is complete, you should find that test.r has completed. Anything
printed as output will be in the r-test.o1231234 file (where 1231234 is the job
ID).
