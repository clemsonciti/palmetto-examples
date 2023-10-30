## LAMMPS

Performance of LAMMPS is sensitive to how the installation is configured relative to the running hardware 
and how `lmp` is called with different process/thread/gpu options. Given the heterogeneous nature of 
Palmetto, we do not maintain a baseline LAMMPS module, but encourage users to build their own LAMMPS. 
Please read the installation and benchmarking instructions below carefully. 

### Installing custom LAMMPS on Palmetto

Reserve a node, and pay attention to its GPU model.

~~~
$ qsub -I -l select=1:ncpus=24:mpiprocs=24:mem=100gb:ngpus=2:gpu_model=p100:interconnect=fdr,walltime=10:00:00
~~~

Create a directory named `software` (if you don't already have it) in your 
home directory, and change to that directory. 

~~~
$ mkdir ~/software
$ cd ~/software
~~~

- Create a subdirectory called `lammps` inside `software`. 
- Download the **preferred**/**required** version of lammps and untar. 
  - https://www.lammps.org/download.html
  - LAMMPS simulations/checkpoints require LAMMPS version to be consistent throughout. 
- In this example, we use the latest stable version of lammps.

~~~
$ mkdir lammps
$ cd lammps
$ wget https://download.lammps.org/tars/lammps-stable.tar.gz
$ tar -xzf lammps-stable.tar.gz 
~~~

- This current `stable` version of lammps after untar will create version 
`23Jun2022`. If you follow this guide in the future, the version might/will 
differ. 

In the recent versions, lammps use `cmake` as their build system. As a result, we will be 
able to build multiple lammps executables within a single source download. 

#### Overview of LAMMPS acceleration packages

LAMMPS currently offers five accelerator packages: `OPT`, `USER-INTEL`, `USER-OMP`, 
`GPU`, `KOKKOS`. 
- `KOKKOS` is an accelerator package that provides a template to allow LAMMPS code to be 
written and interpreted to be accelerated with both GPU (`GPU`) and CPU. 
- In the next section, we will be looking at examples on installing LAMMPS on various 
combination of hardware.


#### KOKKOS/GPU/USER-OMP/

- Change into the previously untar LAMMPS directory (`lammps-23Jun2022`).
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
our templates. 
  - `basic.cmake` contains four basic simulation packages: KSPACE, MANYBODY, MOLECULE, 
  and RIGID
  - `kokkos-cuda.cmake` contains the architectural configuration for the type of 
  GPU card. The default value is `VOLTA70`. 
  - The example default contents of `basic.cmake` and `kokkos-cuda.cmake` are shown
  below. 

~~~
$ more ../cmake/presets/basic.cmake
# preset that turns on just a few, frequently used packages
# this will be compiled quickly and handle a lot of common inputs.

set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()

$ more ../cmake/presets/kokkos-cuda.cmake
# preset that enables KOKKOS and selects CUDA compilation with OpenMP
# enabled as well. This preselects CC 5.0 as default GPU arch, since
# that is compatible with all higher CC, but not the default CC 3.5
set(PKG_KOKKOS ON CACHE BOOL "" FORCE)
set(Kokkos_ENABLE_SERIAL ON CACHE BOOL "" FORCE)
set(Kokkos_ENABLE_CUDA   ON CACHE BOOL "" FORCE)
set(Kokkos_ARCH_VOLTA70 ON CACHE BOOL "" FORCE)
set(BUILD_OMP ON CACHE BOOL "" FORCE)

# hide deprecation warnings temporarily for stable release
set(Kokkos_ENABLE_DEPRECATION_WARNINGS OFF CACHE BOOL "" FORCE)
~~~

- We will need to make copies of `basic.cmake` and `kokko-cuda.cmake`. 
- The names of the newly created files should reflect the nature of this 
current build: a GPU/OMP build for nodes with P100 NVidia cards. 

~~~
$ cp ../cmake/presets/basic.cmake ../cmake/presets/basic-gpu-omp.cmake
$ cp ../cmake/presets/kokkos-cuda.cmake ../cmake/presets/kokkos-p100.cmake
~~~

- The newly created `basic_gpu_omp.cmake` needs to be edited to include 
the three packages, `GPU`, `OPENMP`, and `USER-OMP` to the list of packages in the 
`set(ALL_PACKAGES ...)` line.
- The newly created `kokkos-p100.cmake` needs to be edited to 
change `VOLTA70` to `PASCAL60`. 

~~~
$ nano ../cmake/presets/basic-gpu-omp.cmake
$ nano ../cmake/presets/kokkos-p100.cmake
$ cat ../cmake/presets/basic-gpu-omp.cmake
# preset that turns on just a few, frequently used packages
# this will be compiled quickly and handle a lot of common inputs.

set(ALL_PACKAGES KSPACE MANYBODY MOLECULE RIGID GPU OPENMP USER-OMP)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()
$ cat ../cmake/presets/kokkos-p100.cmake
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
$ module load cmake/3.23.1-gcc/9.5.0 fftw/3.3.10-gcc/9.5.0-mpi-openmp-cu11_1 cuda/11.1.1-gcc/9.5.0 openmpi/4.1.3-gcc/9.5.0-cu11_1-nvK40-nvP-nvV-nvA-ucx gcc/9.5.0
~~~

- Build and install

~~~
cmake -C ../cmake/presets/basic-gpu-omp.cmake -C ../cmake/presets/kokkos-p100.cmake ../cmake
cmake --build . --parallel 24
~~~

- Test on LAMMPS's LJ data
  - **This is only to test installation correctness and not for optimization.**
  - **Do not user the numbers here for your production environment.**

~~~
$ mkdir /scratch1/$USER/lammps
$ cd /scratch1/$USER/lammps
$ wget https://lammps.sandia.gov/inputs/in.lj.txt
$ export PATH="$HOME/software/lammps/lammps-23Jun2022/build-kokkos-gpu-omp/":$PATH
$ mpirun -np 2 lmp -k on g 2 -sf kk -in in.lj.txt > out.1
$ cat out.1
~~~

### LAMMPS optimization

In this section, we will look at several approaches in optimizing and scaling 
LAMMPS execution. 

- **It is important to understand that optimization meaning be able to fully 
utilize all CPUs/GPUs/memory resources requested from Palmetto.**
- **Scaling means that as you increase the amount of resource requested, your 
performance will become better.**
- Optimizing LAMMPS involves understanding the amount of CPU cores/GPU devices 
and distributing these values among parameters to `lmp` call. 

- Let's start a different resource allocation request on Palmetto:

~~~
$ qsub -I -l select=2:ncpus=24:mpiprocs=24:mem=100gb:ngpus=2:gpu_model=p100:interconnect=fdr,walltime=10:00:00
~~~

- This command means that we have asked for two allocations (~ two compute nodes), each 
has 24 CPUs, 100gb of memory, and 2 P100 GPUs. 
- Therefore, **in total**, we have: 48 CPUs, 200gb of memory, and 4 P100 GPUs. 
- Let set up our LAMMPS environment:

~~~
$ cd /scratch1/$USER/lammps
$ module load cmake/3.23.1-gcc/9.5.0 fftw/3.3.10-gcc/9.5.0-mpi-openmp-cu11_1 cuda/11.1.1-gcc/9.5.0 openmpi/4.1.3-gcc/9.5.0-cu11_1-nvK40-nvP-nvV-nvA-ucx gcc/9.5.0
$  export PATH="$HOME/software/lammps/lammps-23Jun2022/build-kokkos-gpu-omp/":$PATH
~~~

- We will use LAMMPS' provided benchmark data for our optimization/scaling observation

~~~
$ cp ~/software/lammps/lammps-23Jun2022/bench/*.rhodo .
$ ls -l *.rhodo
-rw-r--r-- 1 lngo cuuser 6289909 Aug 19 23:08 data.rhodo
-rw-r--r-- 1 lngo cuuser     579 Aug 19 23:08 in.rhodo
~~~

- We will run the following commands to observe different scenarios and 
resulting performance. 
  - Not all contents of output data are displayed. 

- Scenario 1: no GPUs. 
  
~~~
# First run
$ mpirun -np 48 lmp -sf omp -pk omp 1 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 15.353 ns/day, 1.563 hours/ns, 88.846 timesteps/s
Total wall time: 0:00:45
# Second run
$ mpirun -np 24 lmp -sf omp -pk omp 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 1.308 ns/day, 18.347 hours/ns, 7.570 timesteps/s
Total wall time: 0:00:13
# Third run
$ mpirun -np 24 -npernode 12 lmp -sf omp -pk omp 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 15.703 ns/day, 1.528 hours/ns, 90.873 timesteps/s
Total wall time: 0:00:01
# Fourth run
$ mpirun -np 12 -npernode 6 lmp -sf omp -pk omp 4 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 15.710 ns/day, 1.528 hours/ns, 90.914 timesteps/s
Total wall time: 0:00:01
# Fifth run
$ mpirun -np 8 -npernode 4 lmp -sf omp -pk omp 6 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 15.353 ns/day, 1.563 hours/ns, 88.849 timesteps/s
Total wall time: 0:00:02
~~~

The above example demonstrates the different in distribution of 
processes and threads in the `lmp` call. 
  - The multiplication of `-np X` and `omp Y`: `X * Y` must be 
  equal to the total number of cores requested. In this case, 
  it is 48 cores. 
  - The first run will distribute work among all MPI processes 
  (no shared memory). This results in the most inefficient parallel 
  scenario due to added communication cost. 
  - The second run uses two threads per process, improving communication. 
  However, the way `mpirun` is called, all 24 MPI processes will be 
  launched on a single node, and the subsequent threads per process 
  will be on the same node. The performance is improved due to shared-memory
  usage between threads, but it is not as efficient as the remaining runs. 
  - In the remaining runs, the MPI processes are evenly distributed 
  across the two requested node via the `-npernode` flag. Notice that the 
  multiplcation of `-npernode` and `omp` will be equivalent to the 
  number of cores on a single node (`ncpus` value from `qsub`). 
  - Launching more threads/processes than available total cores will lead to 
  performance degradation: 

~~~
$ mpirun -np 48 lmp -sf omp -pk omp 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 1.304 ns/day, 18.398 hours/ns, 7.549 timesteps/s
Total wall time: 0:03:31
~~~

- Scenario 2: with GPUs

~~~
# First run
$ mpirun -np 48 lmp -sf gpu -pk gpu 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 1.031 ns/day, 23.281 hours/ns, 5.966 timesteps/s
Total wall time: 0:07:06
# Second run
$ mpirun -np 24 -npernode 12 lmp -sf gpu -pk gpu 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 2.254 ns/day, 10.650 hours/ns, 13.042 timesteps/s
Total wall time: 0:00:13
# Third Run
$ mpirun -np 8 -npernode 4 lmp -sf gpu -pk gpu 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 16.032 ns/day, 1.497 hours/ns, 92.777 timesteps/s
Total wall time: 0:00:03
# Fourth Run
$ mpirun -np 4 -npernode 2 lmp -sf gpu -pk gpu 2 -in in.rhodo | grep 'Total wall\|Performance'
Performance: 15.358 ns/day, 1.563 hours/ns, 88.879 timesteps/s
Total wall time: 0:00:02
~~~

- Running with GPUs require paying more attention to the distribution of work. 
  - GPUs require data to be loaded from CPU into GPU's memory, and then GPU cores will 
  carry out the computation inside. Once computation is done, results are returned 
  to the CPUs. 
  - With too many CPUs and too few GPUs (First run), there will be bottleneck
  at the data loading stage, causing performance to degrade. 
  - We need to pay attention to the number of GPUs card per node: we have two 
  GPUs per node. 
  - The sweet spot of performance is on the Third Run, with 4 processes per node, 
  meaning each GPU will process data for two processes. 

- The optimization and benchmarking process differs from simulation system to systems. 
What we have here is a procedural approach to benchmarking. You need to study your 
own system carefully to figure out what is the best performance configuration. For 
example, with a different system, a one-CPU-per-GPU gives best performance:

~~~
$ mpirun -np 48 lmp -sf gpu -pk gpu 2 -in in.lj.txt | grep 'Total wall\|Performance'
Performance: 21024.804 tau/day, 48.669 timesteps/s
Total wall time: 0:00:12
$ mpirun -np 24 -npernode 12 lmp -sf gpu -pk gpu 2 -in in.lj.txt | grep 'Total wall\|Performance'
Performance: 51390.335 tau/day, 118.959 timesteps/s
Total wall time: 0:00:05
$ mpirun -np 8 -npernode 4 lmp -sf gpu -pk gpu 2 -in in.lj.txt | grep 'Total wall\|Performance'
Performance: 376119.495 tau/day, 870.647 timesteps/s
Total wall time: 0:00:01
$ mpirun -np 4 -npernode 2 lmp -sf gpu -pk gpu 2 -in in.lj.txt | grep 'Total wall\|Performance'
Performance: 420877.671 tau/day, 974.254 timesteps/s
Total wall time: 0:00:00
~~~
