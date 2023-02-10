---
title: Network Simulator 3
keywords: [ns3]
sidebar: documentation_sidebar
permalink: software_network_simulator.html
---

`Network Simulator 3` or **ns-3** is a discrete-event network simulator for
Internet systems, targeted primarily for research and educational use. ns-3 is
free software, licensed under the GNU GPLv2 license, and is publicly available
for research, development, and use.

In this example, we will show how to install ns-3 to your Palmetto home
directory. More detail can be found here:
<https://www.nsnam.org/wiki/Installation#Installation/>

## Installing Network Simulator 3

1. Request an interactive session

```
$ qsub -I -l select=1:ncpus=16:mem=64gb:mpiprocs=16:interconnect=fdr,walltime=2:00:00
```

2. Load necessary module.

```
$ module add anaconda3/5.0.1 gcc/6.3.0 Qt/5.9.2 sqlite/3.21.0
```

3. Download the latest version of ns-3 (currently 3.29) to your home installed
   directory: (e.g: ~/source/) As this is The first time you build the ns-3
   project you should build using the allinone environment. This will get the
   project configured for you in the most commonly useful way.

```
cd /source/
$ wget https://www.nsnam.org/releases/ns-allinone-3.29.tar.bz2
```

4. Extract the zip file and go to install folder:

```
$ tar -xvf ns-allinone-3.29.tar.bz2
$ cd ns-allinone-3.29
```

5. Install the ns-3:

```
$ ./build.py --enable-examples --enable-tests -- --python=/software/anaconda3/5.0.1/bin/python

```
