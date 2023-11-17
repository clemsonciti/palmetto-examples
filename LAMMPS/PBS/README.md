## LAMMPS

Performance of LAMMPS is sensitive to how the installation is configured relative to the running hardware 
and how `lmp` is called with different process/thread/gpu options. Given the heterogeneous nature of 
Palmetto, we do not maintain a baseline LAMMPS module, but encourage users to build their own LAMMPS. 
Please read the installation and benchmarking instructions below carefully. 

### Installing custom LAMMPS on Palmetto with GPU support

Reserve a node, and pay attention to its GPU model.

~~~
$ qsub -I -l select=1:ncpus=24:mpiprocs=24:mem=100gb:ngpus=1:gpu_model=a100:interconnect=hdr,walltime=10:00:00
~~~

Create a directory named `software_pbs` (if you don't already have it) in your 
home directory, and change to that directory. 

~~~
$ mkdir ~/software_pbs
$ cd ~/software_pbs
~~~

- Download the **preferred**/**required** version of lammps and untar. 
  - https://www.lammps.org/download.html
  - LAMMPS simulations/checkpoints require LAMMPS version to be consistent throughout. 
- In this example, we use the `23Jun2022` version of lammps. Note: later version will raise an error at the end of compiling. 

~~~
$ wget https://download.lammps.org/tars/lammps-23Jun2022.tar.gz
$ tar xzf lammps-stable.tar.gz 
~~~

- According to our test, the version `23Jun2022` can be installed successfully. Later versions, such as `2Aug2023` will raise an error at the end of the compilation. You are encouraged to try newer versions, but if you found any error, please fall back to the `23June2022` version.

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

- Change into the previously untarred LAMMPS directory (`lammps-23Jun2022`).
- Create a directory called `build-kokkos-gpu-omp`
- Change into this directory. 

~~~
$ cd lammps-23Jun2022
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

~~~
$ cat ../cmake/presets/basic.cmake
# preset that turns on just a few, frequently used packages
# this will be compiled quickly and handle a lot of common inputs.

set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()
~~~
~~~
$ cat ../cmake/presets/kokkos-cuda.cmake
# preset that enables KOKKOS and selects CUDA compilation with OpenMP
# enabled as well. This preselects CC 5.0 as default GPU arch, since
# that is compatible with all higher CC, but not the default CC 3.5
set(PKG_KOKKOS ON CACHE BOOL "" FORCE)
set(Kokkos_ENABLE_SERIAL ON CACHE BOOL "" FORCE)
set(Kokkos_ENABLE_CUDA   ON CACHE BOOL "" FORCE)
set(Kokkos_ARCH_PASCAL60 ON CACHE BOOL "" FORCE)
set(BUILD_OMP ON CACHE BOOL "" FORCE)

# hide deprecation warnings temporarily for stable release
set(Kokkos_ENABLE_DEPRECATION_WARNINGS OFF CACHE BOOL "" FORCE)
~~~

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
- The newly generated `kokkos-a100.cmake` needs to be editted to change the GPU type to be 
consistent as we requested in the `qsub` command. In this case, we need to change `PASCAL_60` to 
`AMPERE80`.

~~~
$ cat ../cmake/presets/basic-gpu-omp.cmake
# preset that turns on just a few, frequently used packages
# this will be compiled quickly and handle a lot of common inputs.

set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID GPU OPENMP USER-OMP)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()
~~~
~~~
$ cat ../cmake/presets/kokkos-a100.cmake
# preset that enables KOKKOS and selects CUDA compilation with OpenMP
# enabled as well. This preselects CC 5.0 as default GPU arch, since
# that is compatible with all higher CC, but not the default CC 3.5
set(PKG_KOKKOS ON CACHE BOOL "" FORCE)
set(Kokkos_ENABLE_SERIAL ON CACHE BOOL "" FORCE)
set(Kokkos_ENABLE_CUDA   ON CACHE BOOL "" FORCE)
set(Kokkos_ARCH_AMPERE80 ON CACHE BOOL "" FORCE)
set(BUILD_OMP ON CACHE BOOL "" FORCE)

# hide deprecation warnings temporarily for stable release
set(Kokkos_ENABLE_DEPRECATION_WARNINGS OFF CACHE BOOL "" FORCE)
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
$ module load fftw/3.3.10-gcc/9.5.0-mpi-openmp-cu11_1 anaconda3/2022.05-gcc/9.5.0
~~~ 
!!!$ module load cmake/3.23.1-gcc/9.5.0 fftw/3.3.10-gcc/9.5.0-mpi-openmp-cu11_1 cuda/11.1.1-gcc/9.5.0 openmpi/4.1.3-gcc/9.5.0-cu11_1-nvK40-nvP-nvV-nvA-ucx gcc/9.5.0
~~~

- Build and install

~~~
cmake -C ../cmake/presets/basic-gpu-omp.cmake -C ../cmake/presets/kokkos-a100.cmake ../cmake
cmake --build . --parallel 24
~~~

Once the building process is finished, the executable `lmp` can be found in the direcotry `build-kokkos-gpu-omp`. You can test your built `lmp` on the example given.

- Test on LAMMPS's LJ data
  - **This is only to test installation correctness and not for optimization.**
  - **Do not user the numbers here for your production environment.**

~~
$ mkdir /scratch/$USER/lammps
$ cd /scratch/$USER/lammps
$ wget https://lammps.sandia.gov/inputs/in.lj.txt
$ export PATH="$HOME/software/lammps/lammps-23Jun2022/build-kokkos-gpu-omp/":$PATH
$ mpirun -np 2 lmp -k on g 2 -sf kk -in in.lj.txt > out.1
$ cat out.1
~~

** NOTE: when running on CPUs wtihout GPU support with `lmp` built with this method, the job needs to land on a node with CUDA driver. On Palmetto, CUDA driver is only installed on node where GPUs are equipped. If you only need CPU only version of lammps, we would recommend building the CPU only version using the method below.**

### Installing custom LAMMPS on Palmetto with CPU only 

Reserve a compute node.

~~
$ qsub -I -l select=1:ncpus=24:mpiprocs=24:mem=12gb:interconnect=hdr,walltime=2:00:00
~~

Create a directory named `software_pbs` (if you don't already have it) in your
home directory, and change to that directory.

~~
$ mkdir ~/software_pbs
$ cd ~/software_pbs
~~

- Download the **preferred**/**required** version of lammps and untar.
  - https://www.lammps.org/download.html
  - LAMMPS simulations/checkpoints require LAMMPS version to be consistent throughout.
- In this example, we use the `23Jun2022` version of lammps. Note: later version will raise an error at the end of compiling.

~~
$ wget https://download.lammps.org/tars/lammps-23Jun2022.tar.gz
$ tar xzf lammps-stable.tar.gz
~~

~~~
$ wget https://download.lammps.org/tars/lammps-23Jun2022.tar.gz
$ tar xzf lammps-stable.tar.gz
~~

- According to our test, the version `23Jun2022` can be installed successfully. Later versions, such as `2Aug2023` will raise an error at the end of the compilation. You are encouraged to try newer versions, but if you found any error, please fall back to the `23June2022` version.

In the recent versions, lammps use `cmake` as their build system. As a result, we will be
able to build multiple lammps executables within a single source download.

#### Overview of LAMMPS acceleration packages

LAMMPS currently offers five accelerator packages: `OPT`, `USER-INTEL`, `USER-OMP`,
`GPU`, `KOKKOS`.
- `KOKKOS` is an accelerator package that provides a template to allow LAMMPS code to be
written and interpreted to be accelerated with both GPU (`GPU`) and CPU.
- In the next section, we will be looking at examples on installing LAMMPS on various
combination of hardware.

##### USER-INTEL/OPENMP/USER-OMP/

- Change into the previously untarred LAMMPS directory (`lammps-23Jun2022`).
- Create a directory called `build-intel-omp`
- Change into this directory.

~~~
$ cd lammps-23Jun2022
$ mkdir build-intel-omp
$ cd build-intel-omp
~~~

- In this build, you will need to create one`cmake` file based on
one of the already prepared cmake templates available inside `../cmake/presets` directory
(this is a relative path assuming you are inside the previously created
`build-intel-omp`).
- We will use `../cmake/presets/basic.cmake` as our template.
  - `basic.cmake` contains four basic simulation packages: KSPACE, MANYBODY, MOLECULE,
  and RIGID
  - The example default contents of `basic.cmake` is shown below.

~~~
$ cat ../cmake/presets/basic.cmake
# preset that turns on just a few, frequently used packages
# this will be compiled quickly and handle a lot of common inputs.

set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()
~~~

- We will need to make a copy of `basic.cmake`.
- The names of the newly created files should reflect the nature of this
current build: a INTEL/OMP build.

~~~
$ cp ../cmake/presets/basic.cmake ../cmake/presets/basic-intel-omp.cmake
~~~

- The newly created `basic_intel_omp.cmake` needs to be edited to include
the three packages, `USER-INTEL`, `OPENMP`, and `USER-OMP` to the list of packages in the
`set(ALL_PACKAGES ...)` line. You can use your favorite text editor to do the editting,
and the edited version can be found below.

~~~
$ cat ../cmake/presets/basic-intel-omp.cmake
# preset that turns on just a few, frequently used packages
# this will be compiled quickly and handle a lot of common inputs.

set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID USER-INTEL OPENMP USER-OMP)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()
~~~

- For a template with all simulation packages, take a look
at `../cmake/presets/all_on.cmake`.

- We will need to load the following supporting modules from Palmetto.

~~~
$ module load intel-oneapi-compilers/2022.1.0-gcc/9.5.0 intel-oneapi-mkl/2022.1.0-oneapi/2022.1.0 intel-oneapi-mpi/2021.6.0-oneapi/2022.1.0 
~~~

- Build and install

~~~
cmake -C ../cmake/presets/basic-intel-omp.cmake -C ../cmake/presets/intel.cmake ../cmake
cmake --build . --parallel 24
~~~

Once the building process is finished, the executable `lmp` can be found in the direcotry `build-intel-omp`. You can test your built `lmp` on the example given.
