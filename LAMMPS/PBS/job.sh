#PBS -N lammps_example
#PBS -l select=1:ncpus=8:mpiprocs=8:mem=32gb,walltime=1:00:00
#PBS -j oe

module purge
module load lammps/20220107-gcc/9.5.0-mpi-openmp-cu11_1-nvP-nvV-nvA-kokkos-u-omp

mpirun -n 8 lmp -sf omp -pk omp 1 -in in.lj
