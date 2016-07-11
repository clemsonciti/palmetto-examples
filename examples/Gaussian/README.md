1. Prepare Gaussian input file - we will use `ch4.inp` for this example

2. Examine the submit script and adjust the number of CPUs, memory and walltime

        #PBS -N g09
        #PBS -l select=1:ncpus=2
        #PBS -l walltime=0:10:00

The numbef of CPUs (`ncpus=2`) has to match the number of 
processors in the Gaussian file i.e. `%NProcShared=2`

3. Submit job

        qsub job.sh 

This calculation takes advantage of the `/local_scratch` on the compute
node using variable `$TMPDIR`

4. Examine the result - `ch4.log`


