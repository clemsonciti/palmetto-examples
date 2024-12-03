
## Amber

In this example we will use "[Simple Simulation of Alanine Dipeptide](https://ambermd.org/tutorials/basic/tutorial0/index.php)" test from Amber's official turotial. 

Since we are offering different versions of `Amber`, e.g. mpi and gpu, we provide different submission script for each of them.

### Get the input files for the tutorial:
~~~
$ mkdir /scratch/$USER/amber_tutorial
$ cd /scratch/$USER/amber_tutorial
$ wget https://ambermd.org/tutorials/basic/tutorial0/include/parm7
$ wget https://ambermd.org/tutorials/basic/tutorial0/include/rst7
$ wget https://ambermd.org/tutorials/basic/tutorial0/include/01_Min.in
$ wget https://ambermd.org/tutorials/basic/tutorial0/include/02_Heat.in
$ wget wget https://ambermd.org/tutorials/basic/tutorial0/include/03_Prod.in
~~~~

### Get the submission script:
~~~
$ git clone 
~~~

There are four versions of the submission script for different versions of amber (mpi, gpu) and different job schedulers (pbs, slurm).


#### amber_mpi.slurm (mpi-slurm)

~~~
#!/bin/bash
#SBATCH --job-name=amber_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=00:30:00

module load amber/24.openmpi

cd $SLURM_SUBMIT_DIR


# Minimization
srun sander.MPI -O -i 01_Min.in -o 01_Min.out -p parm7 -c rst7 -r 01_Min.ncrst -inf 01_Min.mdinfo

# Heating process
srun sander.MPI -O -i 02_Heat.in -o 02_Heat.out -p parm7 -c 01_Min.ncrst -r 02_Heat.ncrst -x 02_Heat.nc -inf 02_Heat.mdinfo

# Production
srun pmemd.MPI -O -i 03_Prod.in -o 03_Prod.out -p parm7 -c 02_Heat.ncrst -r 03_Prod.ncrst -x 03_Prod.nc -inf 03_Prod.info
~~~

To submit this pbs script, use the following command:
~~~
sbatch ambser_mpi.slurm
~~~

#### amber_gpu.slurm (gpu-slurm) 

~~~
#!/bin/bash
#SBATCH --job-name=amber_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=00:30:00

module load amber/24.gpu_mpi
cd $SLURM_SUBMIT_DIR

# Minimization
srun sander.quick.cuda.MPI -O -i 01_Min.in -o 01_Min.out -p parm7 -c rst7 -r 01_Min.ncrst -inf 01_Min.mdinfo

# Heating process
srun sander.quick.cuda.MPI -O -i 02_Heat.in -o 02_Heat.out -p parm7 -c 01_Min.ncrst -r 02_Heat.ncrst -x 02_Heat.nc -inf 02_Heat.mdinfo

# Production
srun pmemd.cuda_SPFP.MPI -O -i 03_Prod.in -o 03_Prod.out -p parm7 -c 02_Heat.ncrst -r 03_Prod.ncrst -x 03_Prod.nc -inf 03_Prod.info -AllowSmallBox
~~~

To submit this pbs script, use the following command:
~~~
sbatch ambser_gpu.slurm
~~~

Notice: 1. the last line in the production step includs `-AllowSmallBox`, which is because the cell in the tutorial is too small and not suitable for GPU calculations, we can use specify `-AllowSmallBox` to enforce the code to run. But in the end, the job might still complain and throw an error. 2. ONLY select one gpu card, according to our test, other gpu cards would sit idle if more than one are requested. (RCDE team is still working on this issue)
