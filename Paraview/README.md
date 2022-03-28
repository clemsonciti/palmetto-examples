## Paraview

### Using Paraview+GPUs to visualize very large datasets

Paraview can also use multiple GPUs on Palmetto cluster
to visualize very large datasets.
For this, Paraview must be run in client-server mode.
The "client" is your local machine on which Paraview must be installed,
and the "server" is the Palmetto cluster on which the computations/rendering is done.

1. The version of Paraview on the client needs to match
exactly the version of Paraview on the server.
The client must be running Linux.
You can obtain the source code used for installation of Paraview 5.8.0
on Palmetto from [https://www.paraview.org/download/](https://www.paraview.org/download/).

2. You will need to run the Paraview server on Palmetto cluster.
First, [log in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/), and request an interactive session:

~~~
$ qsub -I -X -l select=1:ncpus=24:mpiprocs=24:ngpus=2:gpu_model=k40:mem=124gb:interconnect=fdr,walltime=1:00:00
~~~

3. Next, launch the Paraview server:

~~~
$ module add paraview/5.8.0-gcc/8.3.1-mpi-cuda10_2
$ module remove openmpi/3.1.6-gcc/8.3.1-cuda10_2-ucx
$ module add openmpi/4.0.5-gcc/8.4.1-ucx
$ export DISPLAY=:0
$ mpiexec -n 8 pvserver -display :0
~~~

The server will be serving on a specific port number (like 11111)
on this node. Note this number down.

3. Next, you will need to set up "port-forwarding" from the lead node
(the node your interactive session is running one) to your local machine.
This can be done by opening a terminal running on the local machine,
and typing the following:

~~~
$ ssh -L 11111:nodeXYZ:11111 username@login.palmetto.clemson.edu
~~~

3. Once port-forwarding is set up,
you can launch Paraview on your local machine.
