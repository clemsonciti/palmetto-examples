#!/bin/bash
#SBATCH --job-name=GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6
#SBATCH --gpus-per-node=2
#SBATCH --mem=22G
#SBATCH --time=0:15:00

cd $SLURM_SUBMIT_DIR

module purge
module load cuda/11.8.0 openmpi intel-oneapi-mkl

#Source the Gromacs environment variable
source /home/$USER/software_slurm/gromacs-2024.2/build_slurm/gmx/bin/GMXRC

# Gromacs recommends having between 2 and 6 threads:
export OMP_NUM_THREADS=6

# get the total number of MPI processes
echo number of MPI processes is $SLURM_NTASKS

# generate binary input file
srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

srun gmx_mpi mdrun -s em.tpr -deffnm job-output
