## Installing and running PyTorch on Palmetto

This page explains how to install the [PyTorch](https://pytorch.org/) 
package for use with GPUs on the cluster, and how to launch a JupyterLab 
Server with PyTorch environment on 
[OpenOnDemand](https://openod02.palmetto.clemson.edu).

### PyTorch installation

1) Request an interactive session on a GPU node.

~~~
$ qsub -I -l select=1:ncpus=16:mem=20gb:ngpus=1:gpu_model=p100:interconnect=10ge,walltime=3:00:00
~~~

2) Load the Anaconda module:

~~~
$ module load anaconda3/2019.10-gcc/8.3.1 cudnn/8.0.4.30-11.1-linux-x64-gcc/8.4.1 cuda/11.1.0-gcc/8.3.1
~~~


3) Create a conda environment called pytorch_env (or any name you like):

~~~
$ conda create -n pytorch python=3.8.3
~~~

4) Activate the conda environment:

~~~
$ source activate pytorch
~~~

5) Install Pytorch with GPU support from the pytorch channel:

~~~
$ conda install pytorch==1.8.0 torchvision==0.9.0 torchaudio==0.8.0 cudatoolkit=11.1 -c pytorch -c conda-forge
~~~

6) Install additional packages (for example, Pandas and JupyterLab)

~~~
$ conda install pandas jupyterlab requests
~~~

7) You can now run Python and test the install:

~~~~
$ python
>>> import torch
>>> print (torch.cuda.is_available())
True
~~~~

![check cuda availability in Torch](./fig/01.png)

Each time you login, you will first need to load the required modules and also activate the pytorch_env conda environment before running Python:

~~~
$ module load anaconda3/2019.10-gcc/8.3.1 cudnn/8.0.4.30-11.1-linux-x64-gcc/8.4.1 cuda/11.1.0-gcc/8.3.1
$ source activate pytorch
~~~

### PyTorch on OpenOnDemand

1) After you have installed Pytorch, install Jupyter in the same conda environment:

$ conda install -c conda-forge jupyterlab
2) Now, set up a Notebook kernel called "Pytorch". For Pytorch with GPU support, do:

$ python -m ipykernel install --user --name pytorch_env --display-name Pytorch
3) Create/edit the file .jhubrc in your home directory:

$ cd
$ nano .jhubrc
Add the following two lines to the .jhubrc file, then exit.

module load cuda/9.2.88-gcc/7.1.0 cudnn/7.6.5.32-9.2-linux-x64-gcc/7.1.0-cuda9_2 anaconda3/2019.10-gcc/8.3.1
4) Log into JupyterHub. Make sure you have GPU in your selection if you want to use the GPU pytorch kernel



5) Once your JupyterHub has started, you should see the Pytorch kernel in your list of kernels in the Launcher.



6) You are now able to launch a notebook using the pytorch with GPU kernel:

