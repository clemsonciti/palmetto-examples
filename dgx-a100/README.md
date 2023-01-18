# NVIDIA DGX A100 User Guide

This document provides a quick user guide on using the NVIDIA DGX A100 nodes on
the Palmetto cluster.

## NVIDIA DGX A100

NVIDIA DGX A100 is a computer system built on NVIDIA A100 GPUs for AI workload.
For more details, please check the
[NVIDIA DGX A100 web Site](https://www.nvidia.com/en-us/data-center/dgx-a100/).

## Request a DGX A100 Node

On Palmetto, the DGX A100 nodes are integrated into the PBS resource and
workload manager. An authorized user should request a DGX A100 Node using a
`qsub` command in one the following ways:

- Request a DGX A100 node in the interactive mode

  `qsub -I -l select=1:ncpus=64:mem=500gb:ngpus=4:gpu_model=a100,walltime=1:00:00 -q dgx_mri`

- Request a DGX A100 node in the batch mode

  `qsub dgx_test.pbs`

The job script `dgx_test.pbs` is shown as follows:

```
#!/bin/sh

#PBS -N dgx_t01
#PBS -q dgx_mri
#PBS -l select=1:ncpus=64:mem=900gb:ngpus=8:gpu_model=a100,walltime=1:00:00

# List available GPUs
nvidia-smi -L

# Run a GPU program
/usr/local/cuda-11.0/extras/demo_suite/busGrind

# other command lines
```

## Use Containers on DGX A100 nodes

Containers simplifies the process of building and running HPC and AI software.
With a container, the entire software environment is packaged into a single
bundle, i.e., an image file.

Among multiple container platforms, singularity has become a preferred choice in
the HPC community. Singularity is designed to allow containers to be executed as
if they were native programs or scripts on a host system: no daemon is required
to build or run containers, and the security model is compatible with shared
systems. To learn how to use Singularity, you can consult
https://sylabs.io/guides/3.7/user-guide/.

### NGC (NVIDIA GPU-Accelerated Containers)

When you work on DGX A100, the NVIDIA GPU-Accelerated Containers, or NGC, is an
essential resource. NGC offers a comprehensive catalog of GPU-accelerated
software for deep learning, machine learning, and HPC. For details, check the
NGC website at https://www.nvidia.com/en-us/gpu-cloud/containers/.

NGC provides a private Docker image registry which you can pull container images
using docker or singularity. The user guide at
https://sylabs.io/guides/3.7/user-guide/singularity_and_docker.html describes
how to use singularity to work with NGC images.

### Common singularity commands

Below are some command commands that you should be familiar with when using
singularity.

- Pull a NGC container image into a singularity image

```
singularity pull docker://nvcr.io/nvidia/pytorch:18.11-py3
```

- Build a singularity image from a NGC container image

```
singularity build tensorflow.sif tensorflow_20.08-tf1-py3.sif
```

- Interact with a singularity container

```
# first, pull or build an image
singularity build lolcow.sif docker://godlovedc/lolcow
# start a container with the image in the interactive mode
singularity shell lolcow.sif
~> whoami
~> id
```

- Run a command within a singularity container

```
# run command within a container
# here cowsay is the program and moo is an argument
singularity exec lolcow.sif cowsay moo
```

- Run a container that comes with a runscript

A container can have a runscript that is executed when the container is run. See
singularity definition file at
https://sylabs.io/guides/3.7/user-guide/definition_files.html for how the
runscript is defined.

```
singularity run lolcow.sif
```

### Access host files

When enabled by the system administrator, Singularity allows you to map
directories on your host system to directories within your container using bind
mounts. This allows you to read and write data on the host system with ease.

A singularity container has its own operating system. When you run a singularity
container, the singularity program swaps the host operating system into the one
inside the container. As a result, the host file system becomes inaccessible.
For you to read and write files on the host system within the container, you
need to tell the singularity program to bind directories on the host system into
the container. There are two primary methods: system-defined bind paths and
user-defined bind paths.

- System-defined bind paths: The system administrator has the ability to define
  what bind paths will be included automatically inside each container. In the
  default configuration, the system default bind points are
  `` $HOME``` ,  `/sys:/sys`,`/proc:/proc`, `/tmp:/tmp`, `/var/tmp:/var/tmp`, `/etc/resolv.conf:/etc/resolv.conf`, `/etc/passwd:/etc/passwd`, and `$PWD`. Here the first path before `:`
  is the path from the host and the second path is the path in the container.

- User-defined bind paths: The Singularity action commands (run, exec, shell,
  and instance start) will accept the --bind/-B command-line option to specify
  bind paths, and will also honor the $SINGULARITY_BIND (or
  $SINGULARITY_BINDPATH) environment variable.

  For example, the following command binds the /scratch2 directory on the host
  system into the /mnt directory in the container:

  `singularity exec --bind /scratch2:/mnt my_container.sif ls /mnt`

### Use NVIDIA GPU inside a singularity container

Singularity commands like run, shell, and exec can take an `--nv` option, which
will setup the container’s environment to use an NVIDIA GPU and the basic CUDA
libraries to run a CUDA enabled application.

The --nv flag will:

- Ensure that the /dev/nvidiaX device entries are available inside the
  container, so that the GPU cards in the host are accessible.

- Locate and bind the basic CUDA libraries from the host into the container, so
  that they are available to the container, and match the kernel GPU driver on
  the host.

- Set the LD_LIBRARY_PATH inside the container so that the bound-in version of
  the CUDA libraries are used by applications run inside the container.

## Example of running a tensorflow program using a singularity container

Step 1. Change into a scratch space

```
mkdir -p /local_scratch/$USER
cd /local_scratch/$USER
```

Step 2. Build or pull a tensorflow image

```
singularity pull docker://tensorflow/tensorflow:latest-gpu
```

Step 3. Run the container with GPU support

```
singularity run --nv tensorflow_latest-gpu.sif
```

Step 4. Execute a python script that verify the GPU is available

```
Singularity> python
>>> from tensorflow.python.client import device_lib
>>> print(device_lib.list_local_devices())
>>> exit()
Singularity> exit
```

Step 5. Write a python program that use the environment inside the container.
Here, we use an existing one that perform image classification.

```
rsync -av /software/examples/dgx_mri/fashion_mnist.py ~/
```

Step 6. Run the program within the container

```
singularity exec --nv tensorflow_latest-gpu.sif python3 ~/fashion_mnist.py
```

## Example files

The example files are located in the directory /software/examples/dgx_mri on
Palmetto. On a DGX A100 node, you can repeat the above procedures by execute:

    bash /software/examples/dgx_mri/dgx_test.pbs

or

    qsub /software/examples/dgx_mri/dgx_test.pbs

- dgx_test.pbs

```
#!/bin/sh

#PBS -N dgx_t01
#PBS -q dgx_mri
#PBS -l select=1:ncpus=256:mem=900gb:ngpus=8:gpu_model=a100,walltime=1:00:00

# 1. List available GPUs
echo "Test #1: List available GPUs"
nvidia-smi -L

# 2. Run a native CUDA program
echo "Test #2: Run a native CUDA program"
/usr/local/cuda-11.0/extras/demo_suite/busGrind

# 3. Run a grogram in a singularity container
echo "Test #3: Run a Tensorflow program within a singularity container"
mkdir -p /local_scratch/$USER/dgx_mri
cd /local_scratch/$USER/dgx_mri
# Pull a docker image to a singularity image file
if [ ! -f tensorflow_latest-gpu.sif ]; then
    singularity pull docker://tensorflow/tensorflow:latest-gpu
fi

# Create a user program
cat <<EOF >$HOME/list_devices.py
from tensorflow.python.client import device_lib

print(device_lib.list_local_devices())
EOF

# Run a program within the singularity image
singularity exec --nv tensorflow_latest-gpu.sif /usr/local/bin/python $HOME/list_devices.py


# 4. Use only the first GPU
echo "Test #4: Run a a Tensorflow program within a singularity container using one GPU"
export SINGULARITYENV_CUDA_VISIBLE_DEVICES=0
singularity exec --nv tensorflow_latest-gpu.sif /usr/local/bin/python list_devices.py

# 5. Run an image classification example using a NGC PyTorch container
# fetch an NGC container
if [ ! -f tensorflow_20.08-tf1-py3.sif ]; then
    singularity pull docker://nvcr.io/nvidia/tensorflow:20.08-tf1-py3
fi
# create a sample program
mkdir -p /scratch2/$USER/mnist
rsync -av /software/examples/dgx_mri/fashion_mnist.py /scratch2/$USER/mnist/
# run the sample program using the container
# here, we also show how to mount a local directory to a container directory using --bind
singularity exec --nv --bind /scratch2/$USER/mnist:/mnt tensorflow_20.08-tf1-py3.sif python3 /mnt/fashion_mnist.py
```

- fashion_mnist.py

```
import tensorflow as tf
from tensorflow import keras
import numpy as np

fashion_mnist = keras.datasets.fashion_mnist
(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

label_cloth_dict = {0:'T-shirt/top', 1:'Trouser', 2:'Pullover', 3:'Dress', 4:'Coat', 5:'Sandal', 6:'Shirt', 7:'Sneaker', 8:'Bag', 9:'Ankle boot' }
def label_name(x):
    return label_cloth_dict[x]

train_images = train_images / 255.0
test_images = test_images / 255.0

simple_model = keras.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dense(10)])

simple_model.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])

simple_model.fit(train_images, train_labels, epochs=15)

test_loss, test_acc = simple_model.evaluate(test_images, test_labels)
print(f'test_loss={test_loss} test_accuracy={test_acc}')
```
