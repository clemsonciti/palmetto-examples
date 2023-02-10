---
title: Simulation of Urban Mobility
keywords: [SUMO]
sidebar: documentation_sidebar
permalink: software_sumo.html
---

SUMO is an open source, highly portable, microscopic and continuous road traffic
simulation package designed to handle large road networks. It allows for
intermodal simulation including pedestrians and comes with a large set of tools
for scenario creation. The code and the issue tracker can be found
[here](https://github.com/eclipse/sumo/)

This page explains how to install the
[SUMO](https://sourceforge.net/projects/sumo/files/) package on the cluster. The
procedure is contributed by Sakib Mahmud Khan - PhD Candidate at Transportation
Cyber-Physical Systems Lab -Glenn Department of Civil Engineering.

## Installing submodules

1. Request an interactive session. For example:

   ```
   $ qsub -I -l select=1:ncpus=6:mem=24gb:interconnect=fdr,walltime=3:00:00
   ```

1. Load the required modules

   ```
   $ module load gcc/7.0.1 cmake/3.6.1
   ```

1. Install [FOX](http://fox-toolkit.org/ftp/), here we used the version 1.6.57

   ```
   $ cd ~/source
   $ wget http://fox-toolkit.org/ftp/fox-1.6.57.tar.gz
   $ cd fox-1.6.57
   $ ./configure --prefix=$HOME/applications
   $ make
   $ make install
   ```

1. Install [PROJ](https://download.osgeo.org/proj), version 4.9.3

   ```
   $ cd ~/source
   $ wget https://download.osgeo.org/proj/proj-4.9.3.tar.gz
   $ cd proj-4.9.3
   $ ./configure --prefix=$HOME/applications
   $ make
   $ make install
   ```

1. Install [GDAL](https://download.osgeo.org/gdal/2.2.0/) version 2.2.0

   ```
   $ cd ~/source
   $ wget https://download.osgeo.org/gdal/2.2.0/gdal-2.2.0.tar.gz
   $ cd gdal-2.2.0
   $ ./configure --prefix=$HOME/applications
   $ make
   $ make install
   ```

1. Install [XCERCES](https://archive.apache.org/dist/xerces/c/3/sources/)

   ```
   $ cd ~/source
   $ wget https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.1.4.tar.gz
   $ cd xerces-c-3.1.4
   $ ./configure --prefix=$HOME/applications
   $ make
   $ make install
   ```

## Installing SUMO

After installing all dependencies, start installing
[SUMO](http://prdownloads.sourceforge.net/sumo/).

Download sumo from
[source](https://sourceforge.net/projects/sumo/files/sumo/version%201.1.0/sumo-src-1.1.0.tar.gz/download)
then upload the code to installed folder:

```
$ cd ~/source
$ tar -xvf sumo-src-1.1.0.tar.gz
$ cd sumo-src-1.1.0
$ ./configure --with-fox-config=$HOME/applications/bin/fox-config --with-proj-gdal=$HOME/applications/ --with-xerces=$HOME/applications
$ make
$ make install
```
