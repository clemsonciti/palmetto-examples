# Jupyter

In addition to running interactive Jupyter notebooks through [Open
OnDemand](https://docs.rcd.clemson.edu/openod/apps/jupyter/), you can also run
them as [batch compute
jobs](https://docs.rcd.clemson.edu/palmetto/jobs/submit/#submit-a-batch-job).
With a batch compute job, you no longer have the resource restrictions from
interactive Open OnDemand jobs.

To create a batch job, you will need a batch script that contains the
appropriate PBS options and loads the appropriate modules and environments.

In this example, we will use

- Anaconda: `anaconda3/2022.10-gcc/9.5.0` (for complete list of version, use `module avail anaconda`),
- Conda Environment: `jupyter_test` (make sure your conda environment has `jupyter` installed within it),
- Notebook file directory: $HOME/jupyter_test
- Notebook file: test.ipynb
- 1 node,
- 4gb memory per node,
- 2 cores per node, and
- 10 minutes.

Replace the above values as needed in the instructions below. You can also add
specialized resource requests (e.g. GPUs). See the [PBS job options
documentation](https://docs.rcd.clemson.edu/palmetto/jobs/submit/#resource-limits-specification)
for details.

Create a file `$HOME/jupyter_test/submit.pbs` with the following content:

```sh
#!/bin/bash
#PBS -N jupyter-test
#PBS -l select=1:ncpus=2:mem=4gb
#PBS -l walltime=00:10:00
#PBS -j oe

set -e

module load anaconda3/2022.10-gcc/9.5.0`
source activate jupyter_test

cd $HOME/jupyter_test
jupyter nbconvert --to notebook --execute --inplace test.ipynb
```

If you want it to output the completed notebook as a new notebook, you could
remove the `--inplace` argument and add `--output`. For example:

```
jupyter nbconvert --to notebook --execute --inplace test.ipynb
```

Once your script is created, you can submit it by connecting to the [login
node](https://docs.rcd.clemson.edu/palmetto/connect/ssh/) and running:

```
cd jupyter_test
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

Once the job is complete, you should find that test.ipynb has completed output
cells (you can open in in a OnDemand Jupyter interactive session to view) and
any error maybe reported in the `jupyter-test.o1865081` file (where 1865081 is
the job ID).

## Convert to HTML or PDF

If you aren't going to be editing the output notebook any more, it maybe helpful
to directly run the Jupyter notebook and convert to PDF or HTML within the batch
job. You can do this by changing the `jupyter nbconvert` command to either:

```
jupyter nbconvert --to html --execute test.ipynb --output=test.html
```

for HTML or:

```
module load latex/2021
jupyter nbconvert --to pdf --execute test.ipynb --output=test.pdf
```

for PDF. In particular, it is easy to read PDFs directly from the file browser
in Open OnDemand (no need to spin up an interactive Jupyter server to view).
