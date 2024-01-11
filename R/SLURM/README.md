# R

In addition to running an interactive R Studio session through [Open
OnDemand](https://docs.rcd.clemson.edu/openod/apps/r_studio_server/), you can also run
them as [batch compute
jobs](https://docs.rcd.clemson.edu/palmetto/jobs_slurm/submit/#submitting-a-batch-job-in-slurm).
With a batch compute job, you no longer have the resource restrictions from
interactive Open OnDemand jobs.

To create a batch job, you will need a batch script that contains the
appropriate Slurm options and loads the appropriate modules and environments.

In this example, we will use

- R: `r/4.2.2` (for complete list of version, use `module avail r/`),
- R script file directory: $HOME/r_test
- R script file: test.r
- 1 node,
- 4gb memory per node,
- 2 cores per node, and
- 10 minutes.

Replace the above values as needed in the instructions below. You can also add
specialized resource requests (e.g. GPUs). See the [Slurm job options
documentation](https://docs.rcd.clemson.edu/palmetto/jobs_slurm/submit/#slurm-job-submission-flags)
for details.

Create a file `$HOME/r_test/submit.sh` with the following content:

```sh
#!/bin/bash
#SBATCH --job-name=r-test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4gb
#SBATCH --time=00:10:00

set -e

module load r/4.2.2

cd $HOME/r_test
Rscript test.r
```

Once your script is created, you can submit it by connecting to the [login
node](https://docs.rcd.clemson.edu/palmetto/connect/ssh/) and running:

```
cd r_test
sbatch submit.sh
```

You can check status of queued and running job status with:

```
squeue
```

or running and completed jobs with:

```
sacct
```

Once the job is complete, you should find that test.r has completed. Anything
printed as output will be in the slurm-1234.out file (where 1234 is the job
ID).
