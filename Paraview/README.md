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
You can obtain the source code used for installation of Paraview 5.0.1
on Palmetto from `/software/paraview/ParaView-v5.0.1-source.tar.gz`.
Copy this file to the client, extract it and compile Paraview.
Compilation instructions can be found in the Paraview
[documentation](http://www.paraview.org/Wiki/ParaView:Build_And_Install).

2. You will need to run the Paraview server on Palmetto cluster.
First, [log in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/), and request an interactive session:

~~~
$ qsub -I -X -l select=4:ncpus=2:mpiprocs=2:ngpus=2:mem=32gb:interconnect=10ge,walltime=1:00:00
~~~

In the above example, we request 4 nodes with 2 GPUs each.

3. Next, launch the Paraview server:

~~~
$ module add paraview/5.0
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
you can launch Paraview on your local machine,
