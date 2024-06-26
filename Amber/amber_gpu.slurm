#!/bin/bash
#SBATCH --job-name=amber_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=00:30:00

# module load amber/22.mpi ##placeholder
source /home/fanchem/software_slurm/amber/22.gpu.mpi/amber.sh
module load anaconda3/2022.10 intel-oneapi-mkl/2022.2.1 openmpi/4.1.6
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi2.so

export OMP_NUM_THREADS=4

cd $SLURM_SUBMIT_DIR

# Minimization
srun sander.quick.cuda.MPI -O -i 01_Min.in -o 01_Min.out -p parm7 -c rst7 -r 01_Min.ncrst -inf 01_Min.mdinfo

# Heating process
srun sander.quick.cuda.MPI -O -i 02_Heat.in -o 02_Heat.out -p parm7 -c 01_Min.ncrst -r 02_Heat.ncrst -x 02_Heat.nc -inf 02_Heat.mdinfo

# Production
srun pmemd.cuda_SPFP.MPI -O -i 03_Prod.in -o 03_Prod.out -p parm7 -c 02_Heat.ncrst -r 03_Prod.ncrst -x 03_Prod.nc -inf 03_Prod.info
