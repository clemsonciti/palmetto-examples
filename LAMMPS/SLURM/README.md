## LAMMPS

Performance of LAMMPS is sensitive to how the installation is configured relative to the running hardware 
and how `lmp` is called with different process/thread/gpu options. Given the heterogeneous nature of 
Palmetto, we do not maintain a baseline LAMMPS module, but encourage users to build their own LAMMPS. 

Users can use the Slurm script `lammps_install.slurm` in this repo to install the GPU and CPU version of Lammps automatically by submitting the Slurm script:
~~~
$ sbatch lammps_install.slurm
~~~


If you are curious on how the lammps is being built, please read the installation and benchmarking instructions below carefully. 

### Installing custom LAMMPS on Palmetto with GPU support

Reserve a node, and pay attention to its GPU model.

~~~
$ salloc --nodes=1 --tasks-per-node=12 --mem=12G --gpus-per-node=a100:1 --time=2:00:00
~~~

Create a directory named `software_slurm` (if you don't already have it) in your 
home directory, and change to that directory. 

~~~
$ mkdir ~/software_slurm
$ cd ~/software_slurm
~~~

- Download the **preferred**/**required** version of lammps and untar. 
  - https://www.lammps.org/download.html
  - LAMMPS simulations/checkpoints require LAMMPS version to be consistent throughout. 
- In this example, we use the `2 Aug 2023` version of lammps, which is the lastest stable version as of 05/24/2024. 

~~~
$ wget https://download.lammps.org/tars/lammps-stable.tar.gz
$ tar xzf lammps-stable.tar.gz
~~~

- According to our test, the version `2 Aug 2023` can be installed successfully. Later versions, You are encouraged to try newer versions, but if you found any error, please fall back to the `2 Aug 2023` version.

In the recent versions, lammps use `cmake` as their build system. As a result, we will be 
able to build multiple lammps executables within a single source download. 

#### Overview of LAMMPS acceleration packages

LAMMPS currently offers five accelerator packages: `OPT`, `USER-INTEL`, `USER-OMP`, 
`GPU`, `KOKKOS`. 
- `KOKKOS` is an accelerator package that provides a template to allow LAMMPS code to be 
written and interpreted to be accelerated with both GPU (`GPU`) and CPU. 
- In the next section, we will be looking at examples on installing LAMMPS on various 
combination of hardware.

##### KOKKOS/GPU/USER-OMP/

- Change into the previously untarred LAMMPS directory (`lammps-2Aug2023`).
- Create a directory called `build-kokkos-gpu-omp`
- Change into this directory. 

~~~
$ cd lammps-2Aug2023
$ mkdir build-kokkos-gpu-omp
$ cd build-kokkos-gpu-omp
~~~

- In this build, you will need to create two `cmake` files, both are based on 
two already prepared cmake templates available inside `../cmake/presets` directory 
(this is a relative path assuming you are inside the previously created 
`build-kokkos-gpu-omp`). 
- We will use `../cmake/presets/basic.cmake` and `../cmake/presets/kokkos-cuda.cmake` 
as our templates. 
  - `basic.cmake` contains four basic simulation packages: KSPACE, MANYBODY, MOLECULE, 
  and RIGID
  - `kokkos-cuda.cmake` contains the architectural configuration for the type of 
  GPU card. The default value is `PASCAL60`. 
  - The example default contents of `basic.cmake` and `kokkos-cuda.cmake` are shown
  below. 

- We will need to make copies of `basic.cmake` and `kokko-cuda.cmake`. 
- The names of the newly created files should reflect the nature of this 
current build: a GPU/OMP build for nodes with A100 NVidia cards (which should be able to 
utilize GPU cards with lower CC). 

~~~
$ cp ../cmake/presets/basic.cmake ../cmake/presets/basic-gpu-omp.cmake
$ cp ../cmake/presets/kokkos-cuda.cmake ../cmake/presets/kokkos-a100.cmake
~~~

- The newly created `basic_gpu_omp.cmake` needs to be edited to include 
the three packages, `GPU`, `OPENMP`, and `USER-OMP` to the list of packages in the 
`set(ALL_PACKAGES ...)` line. You can use your favorite text editor to do the editting, 
and the edited version can be found below.
- The newly generated `kokkos-a100.cmake` needs to be editted to change the GPU type to `AMPERE80`.

~~~
$ sed -i "s/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID GPU OPENMP USER-OMP)/g" ../cmake/presets/basic-gpu-omp.cmake
$ sed -i "s/PASCAL60/AMPERE80/g" ../cmake/presets/kokkos-a100.cmake
~~~

- For a template with all simulation packages, take a look 
at `../cmake/presets/all_on.cmake`. 
- For all available GPU models on Palmetto, refer to the following table

Palmetto GPU        |   Architecture name for Kokkos
--------------------|-------------------------------------
K20 and K40         | KEPLER35
P100                | PASCAL60
V100 and V100S      | VOLTA70
A100                | AMPERE80

- We will need to load the following supporting modules from Palmetto.  

~~~
$ module load cuda/11.8.0 openmpi/5.0.1 
~~~ 

- Build and install

~~~
$ cmake -C ../cmake/presets/basic-gpu-omp.cmake -C ../cmake/presets/kokkos-a100.cmake ../cmake
$ cmake --build . --parallel 12
~~~

Once the building process is finished, the executable `lmp` can be found in the direcotry `build-kokkos-gpu-omp`. You can test your built `lmp` on the example given.

- Test on LAMMPS's LJ data
  - **This is only to test installation correctness and not for optimization.**
  - **Do not use the numbers here for your production environment.**
  - The input files can be downloaded from https://lammps.sandia.gov/inputs/in.lj.txt or from this repo.
~~~
$ mkdir /scratch/$USER/lammps_test
$ cd /scratch/$USER/lammps_test
$ wget https://www.lammps.org/inputs/in.lj.txt
$ export PATH="$HOME/software_slurm/lammps-2Aug2023/build-kokkos-gpu-omp/":$PATH
$ srun lmp -sf gpu -pk gpu 1 -in in.lj.txt > out.gpu
$ cat out.gpu
~~~

-  Example Batch Script for Slurm job
    - This script can also be found in this repo.
    - Note this batch script uses v100 GPU card. Since we compiled with a100 setting, it should be fine to run on GPU cards with lower CC. 
~~~
#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --gpus-per-node=v100:2
#SBATCH --mem=12GB
#SBATCH --time=1:00:00

module load cuda/11.8.0 openmpi/5.0.1

export PATH=/home/$USER/software_slurm/lammps-2Aug2023/build-kokkos-gpu-omp:$PATH

cd $SLURM_SUBMIT_DIR

srun lmp -sf gpu -pk gpu 2 -in in.lj.txt
~~~

**NOTE: when running on CPUs wtihout GPU support with `lmp` built with this method, the job needs to land on a node with CUDA driver. On Palmetto, CUDA driver is only installed on node where GPUs are equipped. If you only need CPU only version of lammps, we would recommend building the CPU only version using the method below.**

### Using the precompiled LAMMPS on Palmetto2 for AMD node
~~~
$ module load aocc lammps
$ lmp
~~~

### Installing custom LAMMPS on Palmetto with CPU only 

Reserve a compute node.

~~~
$ salloc --nodes=1 --tasks-per-node=12 --mem=12G --time=2:00:00
~~~

Create a directory named `software_slurm` (if you don't already have it) in your
home directory, and change to that directory.

~~~
$ mkdir ~/software_slurm
$ cd ~/software_slurm
~~~

- Download the **preferred**/**required** version of lammps and untar.
  - https://www.lammps.org/download.html
  - LAMMPS simulations/checkpoints require LAMMPS version to be consistent throughout.
- In this example, we use the `2 Aug 2023` version of lammps. 

~~~
$ wget https://download.lammps.org/tars/lammps-stable.tar.gz
$ tar xzf lammps-2Aug2023.tar.gz
~~~

- According to our test, the version `2Aug2023` can be installed successfully. You are encouraged to try newer versions, but if you found any error, please fall back to the `2Aug2023` version.

In the recent versions, lammps use `cmake` as their build system. As a result, we will be
able to build multiple lammps executables within a single source download.

#### Overview of LAMMPS acceleration packages

LAMMPS currently offers five accelerator packages: `OPT`, `USER-INTEL`, `USER-OMP`,
`GPU`, `KOKKOS`.
- `KOKKOS` is an accelerator package that provides a template to allow LAMMPS code to be
written and interpreted to be accelerated with both GPU (`GPU`) and CPU.
- In the next section, we will be looking at examples on installing LAMMPS on various
combination of hardware.

##### OPENMPI/OPENMP/USER-OMP/

- Change into the previously untarred LAMMPS directory (`lammps-2Aug2023`).
- Create a directory called `build-openmpi-omp`
- Change into this directory.

~~~
$ cd lammps-2Aug2023
$ mkdir build-openmpi-omp
$ cd build-openmpi-omp
~~~

- In this build, you will need to create one`cmake` file based on
one of the already prepared cmake templates available inside `../cmake/presets` directory
(this is a relative path assuming you are inside the previously created
`build-openmpi-omp`).
- We will use `../cmake/presets/basic.cmake` as our template.
  - `basic.cmake` contains four basic simulation packages: KSPACE, MANYBODY, MOLECULE,
  and RIGID
  - The example default contents of `basic.cmake` is shown below.

- We will need to make a copy of `basic.cmake`.
- The names of the newly created files should reflect the nature of this
current build: a OPENMPI/OMP build.

~~~
$ cp ../cmake/presets/basic.cmake ../cmake/presets/basic-openmpi-omp.cmake
~~~

- The newly created `basic_openmpi_omp.cmake` needs to be edited to include
the two packages, `OPENMP`, and `USER-OMP` to the list of packages in the
`set(ALL_PACKAGES ...)` line. 

~~~
$ sed -i "s/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)/set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID OPENMP USER-OMP)/g" ../cmake/presets/basic-openmpi-omp.cmake
~~~

- For a template with all simulation packages, take a look
at `../cmake/presets/all_on.cmake`.

- We will need to load the following supporting modules from Palmetto.

~~~
$ module load openmpi/5.0.1
~~~

- Build and install

~~~
cmake -C ../cmake/presets/basic-openmpi-omp.cmake -C ../cmake/presets/gcc.cmake ../cmake
cmake --build . --parallel 24
~~~

Once the building process is finished, the executable `lmp` can be found in the direcotry `build-openmpi-omp`. You can test your built `lmp` on the example given.

- Test on LAMMPS's LJ data
  - **This is only to test installation correctness and not for optimization.**
  - **Do not use the numbers here for your production environment.**
  - The input files can be downloaded from https://lammps.sandia.gov/inputs/in.lj.txt or from this repo.
~~~
$ mkdir /scratch/$USER/lammps_test
$ cd /scratch/$USER/lammps_test
$ wget https://www.lammps.org/inputs/in.lj.txt
$ export PATH="$HOME/software_slurm/lammps-2Aug2023/build-openmpi-omp/":$PATH
$ export OMP_NUM_THREADS=1
$ srun lmp -sf omp -pk omp 1 -in in.lj.txt > out.cpu
$ cat out.cpu
~~~

- Example Batch Script for Slurm job
    - This script can also be found in this repo.
~~~
#!/bin/bash
#SBATCH --job-name=lammps_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=8
#SBATCH --mem=12GB
#SBATCH --time=1:00:00

module load openmpi/5.0.1

export PATH=/home/$USER/software_slurm/lammps-2Aug2023/build-openmpi-omp:$PATH

cd $SLURM_SUBMIT_DIR

srun lmp -sf omp -pk omp 8 -in in.lj.txt
~~~
