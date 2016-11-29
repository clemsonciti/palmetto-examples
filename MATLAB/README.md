# Running MATLAB

MATLAB can be run on the cluster either interactively (i.e., using
the Graphical User Interface) or in batch mode.  Here, we demonstrate
an example of running MATLAB in batch mode.

1. Prepare your MATLAB script.  Here we provide a simple script
`test.m`, which creates a symmetric matrix and performs its singular
value decomposition.

2. Prepare the submit script and adjust memory and number of CPUs.
A special consideration in the job script is using the `taskset`
program to set the job affinity of the program.  By default, MATLAB
will attempt to use all available CPU cores in the node it is running
on.  If you have only requested a portion of the CPU cores on a
node, but your application tries to use more, your job will be
terminated.  The `taskset` utility can be used to ensure your
application only uses the number of CPU cores that your job is
assigned:

~~~
taskset -c 0-$(($OMP_NUM_THREADS-1)) matlab -nodisplay
-nodesktop -nosplash -r test > test_results.txt
~~~

Note that the variable `OMP_NUM_THREADS` will automatically be set
to the number of CPU cores your job requested (per chunk).  Thus,
if you want to use the maximum allowable number of CPU cores, you
can set `taskset` to use cores `0-$(($OMP_NUM_THREADS-1))`.

3. Submit the job

~~~
qsub job.sh
~~~

4. Examine the results
