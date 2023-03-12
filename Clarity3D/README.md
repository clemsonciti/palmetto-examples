# Cadence Clarity 3D

***Important***

Before accessing any Cadence produce on the Palmetto cluster, you must request
access to the licences by filling out [this
form](https://clemson.ca1.qualtrics.com/jfe/form/SV_3DyqMQTW1giG83Y). This also
grants you an account on Clarity which allows you to view the product
documentation and tutorials.



## Clarity 3D Workbench Interactive

You can open the Clarity 3D Workbench by using the [Palmetto
Desktop](https://docs.rcd.clemson.edu/palmetto/connect/openod/apps/desktop)
through
Open OnDemand. 

For example, if you want to analyze the input.3dem file in this repository you
can do the following:

1. Request a Palmetto Desktop with 4 cores and 32gb of memory.
2. Open a terminal (within the palmetto desktop). Create a directory, change to
   it, and download the input.3dem:

    ```
    mkdir /scratch/$USER/clarity-workbench-test
    cd /scratch/$USER/clarity-workbench-test
    curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/Clarity3D/input.3dem 
    ```

3. Load the Sigrity module (which includes Clarity 3D), and start the workbench:

    ```
    module load cadence/Sigrity22
    clarity3dworkbench
    ```

4. Select the Clarity 3D license and click Close.
5. Once Clarity is open, click File->Open and select:
   /scratch/<your username>/calrity-workbench-test/input.3dem.
6. You can start the analysis with Solver->Simulation->Start.

## Clarity 3D Workbench Batch

With a batch job, you can submit a model for processing in the background on
Palmetto.  This also makes it easier to user Clarity to spawn workers on several
nodes, speeding up analysis.  We'll provide an example of how to run a batch job
on to analyze that same input.3dem.  We can run all these steps on the login
node since they are not computationally intensive.

1. Create a test directory and download the input.3dem, and submit scripts:
    
    ```
    mkdir /scratch/$USER/clarity-workbench-test
    cd /scratch/$USER/clarity-workbench-test
    curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/Clarity3D/input.3dem 
    curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/Clarity3D/localonly.pbs 
    curl -LOf https://github.com/clemsonciti/palmetto-examples/raw/master/Clarity3D/remote4.pbs 
    ```

2. Run the local script. This will run Clarity on a single node with 4 processes.

    ```
    cd /scratch/$USER/clarity-workbench-test
    mkdir local
    cp input.3dem localonly.pbs local
    cd local
    qsub localonly.pbs
    ```

   This should take about 5 minutes for meshing, and 45 minutes for analysis.

3. Run the 4 node script. This will run Clarity on four nodes with 4 processes
   per node.

    ```
    cd /scratch/$USER/clarity-workbench-test
    mkdir remote4
    cp input.3dem remote4.pbs remote4
    cd remote4
    qsub remote4.pbs
    ```

   This should take about 5 minutes for meshing, and 15 minutes for analysis.
   Note that meshing does not seem to be improved with multiple nodes, but
   analysis is.

4. Once the jobs have completed, you can check the results in the GUI version of
   Clarity.  Follow the steps above to open Clarity 3D workbench, then go to
   Solver->Simulation->Results
