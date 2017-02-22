#PBS -N lammps_example
#PBS -l select=1:ncpus=10:mpiprocs=10:ngpus=1:mem=32gb,walltime=1:00:00
#PBS -j oe

module purge

module load gcc/4.8.1
module load openmpi/1.8.1
module load fftw/3.3.4-g481
module load cuda-toolkit/7.5.18

mpirun -n 8 lmp_palmetto_kokkos_cuda_openmpi -k on t 10 g 1 -sf kk < in.lj
