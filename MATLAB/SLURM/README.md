## MATLAB



### Checking license usage for MATLAB

You can check the availability of MATLAB licenses
using the `lmstat` command:

~~~
$ /hpc/flexlm/lmstat -a -c /hpc/flexlm/licenses/matlab.dat
~~~

### Running the MATLAB graphical interface

To launch the MATLAB graphical interface, you can use the Virtual Desktop from [Open OnDemand] (https://ondemand.rcd.clemson.edu). Once you are connected to the Virtual Desktop, you can open the termial in the virtual desktop and load the MATLAB modules:

~~~
$ module load matlab/2023b
~~~

And then launch the MATLAB program:

~~~
$ matlab
~~~

### Running the MATLAB command line without graphics

To use the MATLAB command-line interface without graphics,
you can request a compute node, load the Matlab module, and then use the `-nodisplay` and `-nosplash` options:

~~~
$ matlab -nodisplay -nosplash
~~~

This will work on both Windows and Mac platforms. To quit matlab command-line interface, type:

~~~
$ exit
~~~

### MATLAB in batch jobs

To use MATLAB in your batch jobs,
you can use the `-r` switch provided by MATLAB,
which lets you **r**un commands specified on the command-line.
For example:

~~~
$ matlab -nodisplay -nosplash -r myscript
~~~

will run the MATLAB script `myscript.m`,
Or:

~~~
$ matlab -nodisplay -nosplash < myscript.m > myscript_results.txt
~~~

will run the MATLAB script `myscript.m` and write the output to *myscript_results.txt* file.
Thus, an example batch job using MATLAB could have
a batch script as follows:

~~~
#!/bin/bash

#SBATCH --job-name=test_matlab
#SBATCH --nodes=1
#SBATCH --tasks-per-node=4
#SBATCH --mem=10G
#SBATCH --time=1:00:00

module add matlab/2023b

cd $SLURM_SUBMIT_DIR

matlab -nodisplay -nosplash < myscript.m > myscript_results.txt
~~~

### Compiling MATLAB code to create an executable

Often, you need to run a large number of MATLAB jobs
concurrently (e.g,m each job operating on different data).
In such cases, you can avoid over-utilizing MATLAB licenses
by *compiling* your MATLAB code into an executable.
This can be done from within the MATLAB command-line as follows:

~~~
$ matlab -nodisplay -nosplash
>> mcc -R -nodisplay -R -singleCompThread -R -nojvm -m mycode.m
~~~

Note: MATLAB will try to use all the available CPU cores
on the system where it is running, and this presents a problem
when your compiled executable on the cluster where available
cores on a single node might be shared amongst multiple users.
You can disable this "feature" when you compile your code by
adding the `-R -singleCompThread` option, as shown above.

The above command will produce the executable `mycode`, corresponding
to the M-file `mycode.m`. If you have multiple M-files in your project
and want to create a single executable, you can use
a command like the following:

~~~
>> mcc -R -nodisplay -R -singleCompThread -R -nojvm -m my_main_code.m myfunction1.m myfunction2.m myfunction3.m
~~~

Once the executable is produced,
you can run it like any other executable in your batch jobs.
Of course, you'll also need the same `matlab` loaded for your job's runtime environment.
