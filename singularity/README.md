## Singularity

[Singularity](https://www.sylabs.io/)
is a tool for creating and running
[containers](https://en.wikipedia.org/wiki/Operating-system-level_virtualization)
on HPC systems,
similar to [Docker](https://www.docker.com/).

For further information on Singularity,
and on downloading, building and running containers with Singularity,
please refer to the [Singularity documentation](https://www.sylabs.io/docs/).
This page provides information about singularity specific to the Palmetto cluster.

### Running Singularity

Singularity is installed on all of the Palmetto compute nodes and the Palmetto LoginVMs, but it **IS NOT** present on the login.palmetto.clemson.edu node.

To run singularity, you may simply run `singularity` or more specifically `/bin/singularity`.

e.g.
```
$ singularity --version
singularity version 3.5.3-1.el7
```

### An important change for existing singularity users

Formerly, Palmetto administrators had installed singularity as a "software module" on Palmetto, but that is no longer the case. If your job scripts have any statements that use the singularity module, then those statements will need to be completely removed; otherwise, your job script may error.

Remove any statements from your job scripts that resemble the following lines:
```
module <some_command> singularity
```

### Where to download containers

Containers can be downloaded from DockerHub

* [DockerHub](https://hub.docker.com/)
contains containers for various software packages,
and Singularity is
[compatible with Docker images](https://sylabs.io/guides/3.5/user-guide/singularity_and_docker.html).

* [SingularityHub](https://singularity-hub.org/)

* The [NVIDIA GPU Cloud](https://ngc.nvidia.com/signin/email) for GPU-optimized images.

* Many individual projects contain specific instructions for installation via
Docker and/or Singularity, and may host pre-built images in other locations.

### Example: Running OpenFOAM using Singularity

As an example, we consider installing and running the OpenFOAM CFD solver using Singularity.
OpenFOAM can be quite difficult to install manually,
but singularity makes it very easy.
This example shows how to use singularity interactively,
but singularity containers can be run in batch jobs as well.

Start by requesting an interactive job.

NOTE: Singularity can only be run on the compute nodes and Palmetto Login VMs:

```
$ qsub -I -l select=1:ngpus=2:ncpus=16:mpiprocs=16:mem=120gb:interconnect=10ge,walltime=5:00:00
```

We recommend that all users store built singularity images
in their `/home` directories.
Singularity images can be quite large,
so be sure to delete unused or old images:

```
$ mkdir ~/singularity-images
$ cd ~/singularity-images
```

Next, we download the singularity image for OpenFOAM from DockerHub.
This takes a few seconds to complete:

```
$ singularity pull docker://openfoam/openfoam6-paraview54
```

Once the image is downloaded,
we are ready to run OpenFOAM.
We use `singularity shell` to start a container,
and run a shell in the container.

The `-B` option is used to "bind" the `/scratch2/$USER` directory
to a directory named `/scratch` in the container.

We also the `--pwd` option to specify the working directory in the running container
(in this case `/scratch`).
This is **always** recommended.

Typically, the working directory may be the $TMPDIR directory or
one of the scratch directories.

```
$ singularity shell -B /scratch2/atrikut:/scratch --pwd /scratch openfoam6-paraview54.simg
```

Before running OpenFOAM commands, we need to source a few environment variables
(this step is specific to OpenFOAM):

```
$ source /opt/openfoam6/etc/bashrc
```

Now, we are ready to run a simple example using OpenFOAM:

```
$ cp -r $FOAM_TUTORIALS/incompressible/simpleFoam/pitzDaily .
$ cd pitzDaily
$ blockMesh
$ simpleFoam
```

The simulation takes a few seconds to complete,
and should finish with the following output:

```
smoothSolver:  Solving for Ux, Initial residual = 0.00012056, Final residual = 7.8056e-06, No Iterations 6
smoothSolver:  Solving for Uy, Initial residual = 0.000959834, Final residual = 6.43909e-05, No Iterations 6
GAMG:  Solving for p, Initial residual = 0.00191644, Final residual = 0.000161493, No Iterations 3
time step continuity errors : sum local = 0.00681813, global = -0.000731564, cumulative = 0.941842
smoothSolver:  Solving for epsilon, Initial residual = 0.000137225, Final residual = 8.98917e-06, No Iterations 3
smoothSolver:  Solving for k, Initial residual = 0.000215144, Final residual = 1.30281e-05, No Iterations 4
ExecutionTime = 10.77 s  ClockTime = 11 s


SIMPLE solution converged in 288 iterations

streamLine streamlines write:
    seeded 10 particles
    Tracks:10
    Total samples:11980
    Writing data to "/scratch/pitzDaily/postProcessing/sets/streamlines/288"
End
```

We are now ready to exit the container:

```
$ exit
```

Because the directory `/scratch` was bound to `/scratch2/$USER`, the simulation output is available in
the directory `/scratch2/$USER/pitzDaily/postProcessing/`:

```
$ ls /scratch2/$USER/pitzDaily/postProcessing/
sets
```

### GPU-enabled software using Singularity containers (NVIDIA GPU Cloud)

Palmetto also supports use of images provided by the [NVIDIA GPU Cloud (NGC)](https://www.nvidia.com/en-us/gpu-cloud/).

The provides GPU-accelerated HPC and deep learning containers for scientific computing.
NVIDIA tests HPC container compatibility with the Singularity runtime through a rigorous QA process.

### Pulling NGC images

Singularity images may be pulled directly from the Palmetto GPU compute nodes,
an interactive job is most convenient for this.
Singularity uses multiple CPU cores when building the image
and so it is recommended that a minimum of 4 CPU cores are reserved.
For instance to reserve 4 CPU cores, 2 NVIDIA Pascal GPUs, for 20 minutes the following could be used:

```
$ qsub -I -lselect=1:ncpus=4:mem=2gb:ngpus=2:gpu_model=p100,walltime=00:20:00
```

Wait for the interactive job to give you control over the shell.

Before pulling an NGC image, authentication credentials must be set.
This is most easily accomplished by setting the following variables in the build environment.

```
$ export SINGULARITY_DOCKER_USERNAME='$oauthtoken'
$ export SINGULARITY_DOCKER_PASSWORD=<NVIDIA NGC API key>
```

More information describing how to obtain and use your NVIDIA NGC API key can be found
[here](https://docs.nvidia.com/ngc/ngc-getting-started-guide/index.html).

Once credentials are set in the environment,
we’re ready to pull and convert the NGC image to a local Singularity image file.
The general form of this command for NGC HPC images is:

```
$ singularity build <local_image> docker://nvcr.io/<registry>/<app:tag>
```

This singularity build command will download the `app:tag` NGC Docker image,
convert it to Singularity format,
and save it to the local file named local_image.

For example to pull the namd NGC container tagged with version 2.12-171025
to a local file named `namd.simg` we can run:

```
$ singularity build ~/namd.simg docker://nvcr.io/hpc/namd:2.12-171025
```

After this command has finished we'll have a Singularity image file, `namd.simg`:

### Running NGC containers

Running NGC containers on Palmetto presents few differences from the run instructions provided on NGC for each application.
Application-specific information may vary so it is recommended that you follow the
container specific documentation before running with Singularity.
If the container documentation does not include Singularity information,
then the container has not yet been tested under Singularity.

As all NGC containers are optimized for NVIDIA GPU acceleration we will always want to add the `--nv` flag
to enable NVIDIA GPU support  within the container.

The Singularity command below represents the standard form of the Singularity command used on the Palmetto cluster.
It will mount the present working directory on the host to `/host_pwd` in the container process and
set the present working directory of the container process to `/host_pwd`
This means that when our process starts it will be effectively running in the host directory
the singularity command was launched from.

```
$ singularity exec --nv -B $(pwd):/host_pwd --pwd /host_pwd <image.simg> <cmd>
```
