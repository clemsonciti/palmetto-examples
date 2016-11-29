# Running arrays of jobs

Sometimes, you may want to run several jobs concurrently, each
operating on different data or input.  In this case, instead of
submitting several jobs one after the other, you can submit a *job
array*, which will allow you to submit several jobs using a single
script.

In this example, we use a job array to submit 8 jobs concurrently.
Each job will call the program `quadratic.py`.  This program expects
three inputs as command-line arguments.  For example, when the
program is called with inputs `2`, `0` and `-98`:

    python quadratic.py 2 0 -98

it prints the following output:

    x1 = 7.0 x2 = -7.0

We have several such inputs that we would like to run the program
with (listed in the file `inputs.txt`).  For each set of inputs,
we would like to submit a job that runs `quadratic.py` with one set
of inputs.  So the first job will use the inputs `2 0 -98`, the
second job will use the inputs `4 2 -42`, and so on.

Since we have 8 sets of inputs, we must launch 8 jobs.  In order
to do this concurrently, we define a *job array* (`job_array.sh`)
using the special PBS directive `-J`.  Here, `-J 1-8` defines a
range for our jobs.  For each of these jobs, the variable
`PBS_ARRAY_INDEX` assumes one value in this range.  For the first
job, `PBS_ARRAY_INDEX` assumes the value `1`, for the second job,
it assumes the value `2`, and for the last job, it assumes the value
`8`.

For example, for job #5, `PBS_ARRAY_INDEX` has the value `5`, so
the job script becomes:

~~~ #!/bin/bash

#PBS -N quadratic #PBS -l select=1:ncpus=1:interconnect=1g #PBS -l
walltime=00:02:00 #PBS -j oe #PBS -J 1-8

cd $PBS_O_WORKDIR

inputs=( $(sed -n 5p inputs.txt) )

./quadratic.py ${inputs[0]} ${inputs[1]} ${inputs[2]}
~~~

Note that `sed -n 5p inputs.txt` extracts the fifth line from the
file `inputs.txt`.
