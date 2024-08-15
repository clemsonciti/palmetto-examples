#!/bin/bash
#SBATCH --job-name=GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=96
#SBATCH --mem=90G
#SBATCH --time=10:15:00
#SBATCH --constraint=cpu_gen_genoa

cd $SLURM_SUBMIT_DIR

module purge
module load cuda openmpi intel-oneapi-mkl

#Source the Gromacs environment variable
source /home/$USER/software_slurm/gromacs-2024.2/build_slurm/gmx/bin/GMXRC

# get the total number of MPI processes
echo number of MPI processes is $SLURM_NTASKS

# generate binary input file
mpirun -np $SLURM_NTASKS gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

mpirun -np $SLURM_NTASKS gmx_mpi mdrun -s em.tpr -deffnm job-output
