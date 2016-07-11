1. Prepare Gaussian input file (we will use `ch4.inp` for this example)

2. Examine the `g09.pbs` script and change the name of the input file 
   (`ch4.inp` in this example). Adjust number of reqested nodes and cores
   per node, the script will make sure that Gaussian is aware of all 
   of them.

   In `g09.pbs` script, the lines 

        # user prepared input file
        input=ch4.inp

   define Gaussian input file. Change `input=ch4.inp` giving the
   name of your input file (with `.inp` extension).

3. Submit job

        $ qsub g09.pbs

4. After the job has finished, examine the results, `ch4.log` in our case.
   If the calculation completed you will notice message at the end 
   of the output file "Normal termination of Gaussian 09"
