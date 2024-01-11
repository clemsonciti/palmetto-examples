# Jupyter

In addition to running interactive Jupyter notebooks through [Open
OnDemand](https://docs.rcd.clemson.edu/openod/apps/jupyter/), you can also run
them as [batch compute
jobs](https://docs.rcd.clemson.edu/palmetto/jobs_slurm/submit/#submitting-a-batch-job-in-slurm).
With a batch compute job, you no longer have the resource restrictions from
interactive Open OnDemand jobs.

To create a batch job, you will need a batch script that contains the
appropriate Slurm options and loads the appropriate modules and environments.

In this example, we will use

- Anaconda: `anaconda3/2022.10` (for complete list of version, use `module avail anaconda`),
- Conda Environment: `jupyter_test` (make sure your conda environment has `jupyter` installed within it),
- Notebook file directory: $HOME/jupyter_test
- Notebook file: test.ipynb
- 1 node,
- 4gb memory per node,
- 2 cores per node, and
- 10 minutes.

Replace the above values as needed in the instructions below. You can also add
specialized resource requests (e.g. GPUs). See the [Slurm job options
documentation](https://docs.rcd.clemson.edu/palmetto/jobs_slurm/submit/#slurm-job-submission-flags)
for details.

Create a file `$HOME/jupyter_test/submit.sh` with the following content:

```sh
#!/bin/bash
#SBATCH --job-name=jupyter-test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4gb
#SBATCH --time=00:10:00

set -e

module load anaconda3/2022.10
source activate jupyter_test

cd $HOME/jupyter_test
jupyter nbconvert --to notebook --execute --inplace test.ipynb
```

If you want it to output the completed notebook as a new notebook, you could
remove the `--inplace` argument and add `--output`. For example:

```
jupyter nbconvert --to notebook --execute test.ipynb --output out.ipynb
```

Once your script is created, you can submit it by connecting to the [login
node](https://docs.rcd.clemson.edu/palmetto/connect/ssh/) and running:

```
cd jupyter_test
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

Once the job is complete, you should find that test.ipynb has completed output
cells (you can open in in a OnDemand Jupyter interactive session to view) and
any error maybe reported in the `slurm-4371.out` file (where 4371.out is the job
ID).
