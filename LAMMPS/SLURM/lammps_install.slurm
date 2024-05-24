#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=12
#SBATCH --mem=12G
#SBATCH --gpus-per-node=a100:1
#SBATCH --time=3:0:0


echo "-------installing the gpu version-------"
mkdir ~/software_slurm
cd ~/software_slurm
wget https://download.lammps.org/tars/lammps-stable.tar.gz
tar xzf lammps-stable.tar.gz
cd lammps-2Aug2023
mkdir build-kokkos-gpu-omp
cd build-kokkos-gpu-omp
cp ../cmake/presets/basic.cmake ../cmake/presets/basic-gpu-omp.cmake
cp ../cmake/presets/kokkos-cuda.cmake ../cmake/presets/kokkos-a100.cmake
sed -i "s/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID GPU OPENMP USER-OMP)/g" ../cmake/presets/basic-gpu-omp.cmake
sed -i "s/PASCAL60/AMPERE80/g" ../cmake/presets/kokkos-a100.cmake
module load cuda/11.8.0 openmpi/5.0.1 
cmake -C ../cmake/presets/basic-gpu-omp.cmake -C ../cmake/presets/kokkos-a100.cmake ../cmake
cmake --build . --parallel 12

echo "-------installing the cpu version-------"
cd /home/$USER/software_slurm/lammps-2Aug2023
mkdir build-openmpi-omp
cd build-openmpi-omp
cp ../cmake/presets/basic.cmake ../cmake/presets/basic-openmpi-omp.cmake
sed -i "s/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID OPENMP USER-OMP)/g" ../cmake/presets/basic-openmpi-omp.cmake
module purge
module load openmpi/5.0.1
cmake -C ../cmake/presets/basic-openmpi-omp.cmake -C ../cmake/presets/gcc.cmake ../cmake
cmake --build . --parallel 12

echo "-------- installation finished----------"
echo "INFO: the gpu version is installed at /home/$USER/software_slurm/build-kokkos-gpu-omp"
echo "INFO: the cpu version is installed at /home/$USER/software_slurm/build-openmpi-omp"
echo "---------------------------------------"
