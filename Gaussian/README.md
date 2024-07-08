1. Prepare Gaussian input file - we will use `ch4.inp` for this example

2. Examine the submit script and adjust the number of CPUs, memory and walltime

        #SBATCH --job-name=g16
        #SBATCH --nodes=1
        #SBATCH --tasks-per-node=2
        #SBATCH --time=0:10:00
        #SBATCH --mem=4G

The numbef of CPUs (`tasks-per-node=2`) has to match the number of 
processors in the Gaussian file i.e. `%NProcShared=2`

3. Submit job

        sbatch g16.slurm

This calculation takes advantage of the `/local_scratch` on the compute
node using variable `$TMPDIR`

4. Examine the result - `ch4.log`


