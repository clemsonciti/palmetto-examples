#PBS -N adh_cubic
#PBS -l select=1:ncpus=12:mpiprocs=2:ngpus=2:gpu_model=a100:interconnect=hdr:mem=22gb

cd $PBS_O_WORKDIR

source /home/$USER/software/gromacs-2023.3/build_pbs/gmx/bin/GMXRC
module load intel-oneapi-mkl/2022.1.0-oneapi openmpi/4.1.3-gcc/9.5.0-cu11_6-nvP-nvV-nvA-ucx

export OMP_NUM_THREADS=6

# get the total number of MPI processes
N_MPI_PROCESSES=`cat $PBS_NODEFILE | wc -l`
echo number of MPI processes is $N_MPI_PROCESSES

# generate binary input file
gmx_mpi grompp -f rf_verlet.mdp -p topol.top -c conf.gro -o em.tpr

mpirun -np $N_MPI_PROCESSES -npernode 2 gmx_mpi mdrun -s em.tpr -deffnm job-output