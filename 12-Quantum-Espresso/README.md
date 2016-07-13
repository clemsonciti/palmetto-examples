This example shows how to run simple calculations using Quantum Espresso 
on Palmetto cluster. The same example will be run using MPI enabled `pw.x` 
and MPI+GPU enabled `pw-gpu.x`. 

1. Examine example `atom.in` taken from test suite of Quantum Espresso 5.4.
  The pseudo-potential directory is set to the current working directory in our 
  case `pseudo_dir = './'`. This folder contains file `O.pz-rrkjus.UPF` needed
  for the calculation. 

2. Check script `run.sh`. We will request 2 nodes with 2 cores per node (2 MPI
  processes per node) and 2 GPUs per node. Quantum Espresso is available via `espresso/5.4` 
  module

      module load espresso/5.4

  We will run the same example using standard and GPU enabled version, both of them
  are started in similar form 

      mpirun pw.x < atom.in > output.file
      mpirun pw-gpu.x < atom.in > output.file-gpu

3. While the code is running, the GPU utilization may be monitored using 
  command `nvidia-smi --loop=1` on a compute node. 
