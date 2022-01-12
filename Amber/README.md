
## Amber

In this example we will use "alp" test from Amber's test suite.
To get the files relevant to this example:

~~~
$ module add examples
$ example get Amber
$ cd Amber && ls

amber.pbs  coords  md.in  prmtop  README.md
~~~

Examine the batch script `amber.pbs`, and adjust
the names of the files i.e. input and coordinates files.
Also, adjust the number of nodes, processors per node and walltime.
To submit the job:

~~~
qsub amber.pbs 
~~~

Results will be saved in the `md.out` file (in our example).
