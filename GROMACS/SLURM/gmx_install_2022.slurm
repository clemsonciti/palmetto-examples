#!/bin/sh
#SBATCH --job-name=gmx_install
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --gpus-per-node=1
#SBATCH --mem=22G
#SBATCH --time=2:00:00

cd $SLURM_SUBMIT_DIR

mkdir /home/$USER/software_slurm
cd /home/$USER/software_slurm
wget ftp://ftp.gromacs.org/gromacs/gromacs-2022.6.tar.gz
tar zxvf gromacs-2022.6.tar.gz
cd gromacs-2022.6
module purge

# Build GPU version
module load cuda/12.3.0 openmpi 
mkdir build_slurm
cd build_slurm
cmake .. -DGMX_MPI=on -DGMX_GPU=CUDA -DGMX_BUILD_OWN_FFTW=ON -DGMX_SIMD=AVX_512 -DCMAKE_INSTALL_PREFIX=/home/$USER/software_slurm/gromacs-2022.6/gmx_gpu
make -j 12
make install -j 12

echo "INFO: GROMACS is installed at /home/$USER/software_slurm/gromacs-2022.6/gmx_gpu"
echo "INFO: Adding following line to your submission script"
echo "      source /home/$USER/software_slurm/gromacs-2022.6/gmx_gpu/bin/GMXRC"

# Build CPU version
rm -r *
module purge
module load openmpi 
cmake .. -DGMX_MPI=on -DGMX_BUILD_OWN_FFTW=ON  -DGMX_SIMD=AVX_512 -DCMAKE_INSTALL_PREFIX=/home/$USER/software_slurm/gromacs-2022.6/gmx_cpu
make -j 12
make install -j 12

echo "INFO: GROMACS is installed at /home/$USER/software_slurm/gromacs-2022.6/gmx_cpu"
echo "INFO: Adding following line to your submission script"
echo "      source /home/$USER/software_slurm/gromacs-2022.6/gmx_cpu/bin/GMXRC"



