# NAMD

> **Note** NAMD can ONLY run on a single node on Palmetto2.
 
NAMD is a molecular dynamics simulation software written in charm++. Currently namd/3.06b is available on the palmetto cluster.
The official website is at http://www.ks.uiuc.edu/Research/namd/.


# NAMD versions on Palmetto2
There are three versions of NAMD on Palmetto2: 
- 3.06b with CPU only
- 3.06b with GPU support
- 3.0b from ngc container

~~~
$ module avail namd

----------------------------------------------------------- Commercial/External Modules ------------------------------------------------------------
   namd/3.06b.cpu    namd/3.06b (D)    ngc/namd/3.0-beta2
~~~

### Running NAMD in Batch mode

To run NAMD in batch mode on Palmetto2 cluster,
you can use the job scripts in this repo as example for CPU only or GPU enabled NAMD
- `namd_cpu.slurm`: CPU only
- `namd_gpu.slurm`: GPU enabled

All the necessary input file are also included in this repo.
- `equil_min.namd`: minimization step 
- `equil_k0.5.namd` or `equil_k0.5_gpu.namd`: molecular dynamic step

> **Note** `CUDASOAintegrate on` is included in equil_k0.5_gpu.namd, which can utilize the GPU more efficiently. **BUT**, do not use this parameter in the minimization step. The details can be found at the [official website](https://www.ks.uiuc.edu/Research/namd/alpha/3.0alpha/).
 
