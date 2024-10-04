#!/bin/bash
#SBATCH --job-name=GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --gpus-per-node=2
#SBATCH --mem=22G
#SBATCH --time=10:15:00

cd $SLURM_SUBMIT_DIR

module purge
module load cuda/12.3.0 openmpi intel-oneapi-mkl

#Source the Gromacs environment variable
source /home/$USER/software_slurm/gromacs-2024.3/gmx_gpu/bin/GMXRC

# get the total number of MPI processes
echo number of MPI processes is $SLURM_NTASKS

# generate binary input file
gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

mpirun -np $SLURM_NTASKS gmx_mpi mdrun -s em.tpr -deffnm job-output
