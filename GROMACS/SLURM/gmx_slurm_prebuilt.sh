#SBATCH -N GROMACS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6
#SBATCH --gpus-per-node=a100:2
#SBATCH --mem=22G
#SBATCH --time=0:15:00

cd $SLURM_SUBMIT_DIR

module purge
module use /software/ModuleFiles/modules/linux-rocky8-x86_64/
module load gromacs/2021.5-gcc/9.5.0-openmpi/4.1.3-mpi-openmp-cu11_1

# Gromacs recommends having between 2 and 6 threads:
export OMP_NUM_THREADS=6

# generate binary input file
srun gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

# get the total number of MPI processes
echo number of MPI processes is $SLURM_NTASKS

mpirun -np $SLURM_NTASKS -npernode 2 gmx_mpi mdrun -s em.tpr -deffnm job-output