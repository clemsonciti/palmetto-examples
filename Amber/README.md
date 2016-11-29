1. Prepare Amber input files. In this example we will use "alp" test
   from Abmber's test suite. 

2. Examine `amber.pbs` file and adjust the names of the files i.e. input
   and coordinates files. Also, adjust the number of nodes, processors per 
   node and walltime.

3. Submit the job

        qsub amber.pbs 

4. Results will be saved in the `md.out` file (in our example). 
