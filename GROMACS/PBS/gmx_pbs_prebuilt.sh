#PBS -N GROMACS
#PBS -l select=1:ncpus=12:mpiprocs=2:ngpus=2:gpu_model=a100:interconnect=hdr:mem=22gb
#PBS -j oe
#PBS -l walltime=0:15:00

cd $PBS_O_WORKDIR

module purge
module load gromacs/2021.5-gcc/9.5.0-openmpi/4.1.3-mpi-openmp-cu11_1

# Gromacs recommends having between 2 and 6 threads:
export OMP_NUM_THREADS=6

# get the total number of MPI processes
N_MPI_PROCESSES=`cat $PBS_NODEFILE | wc -l`
echo number of MPI processes is $N_MPI_PROCESSES

# generate binary input file
gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

mpirun -np $N_MPI_PROCESSES -npernode 2 gmx_mpi mdrun -s em.tpr -deffnm job-output