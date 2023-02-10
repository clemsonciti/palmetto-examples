---
title: Open Babel
keywords: [openbabel]
sidebar: documentation_sidebar
permalink: software_openbabel.html
---

This page instructs how to install Open Babel software to Palmetto The code and
the issue tracker can be found
[here](https://openbabel.org/docs/dev/Installation/install.html)

1. Request an interactive session. For example:

   ```
   $ qsub -I -l select=1:ncpus=8:mem=24gb:interconnect=fdr,walltime=3:00:00
   ```

1. Load the required modules

   ```
   $ module load cmake/3.6.1 gcc/4.8.1
   ```

1. Install Eigen (latest version 3.3.7)

   ```
   $ wget http://bitbucket.org/eigen/eigen/get/3.3.7.tar.gz
   $ tar -xvf 3.3.7.tar.gz
   $ cd eigen-eigen-323c052e1731
   $ mkdir build
   $ cd build
   $ cmake -DCMAKE_INSTALL_PREFIX=$HOME/applications/ ..
   $ make install
   ```

1. Install wxWidgets (latest version 3.1.2)

   ```
   $ wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.2/wxWidgets-3.1.2.tar.bz2
   $ tar -xvf wxWidgets-3.1.2.tar.bz2
   $ cd wxWidgets-3.1.2
   $ configure --prefix=$HOME/applications
   $ make
   $ make install
   ```

1. Download Open Babel from
   [source](https://sourceforge.net/projects/openbabel/files/openbabel/2.4.1/openbabel-2.4.1.tar.gz/download).
   Here we download the latest version 2.4.1.

   Upload the package openbabel-2.4.1.tar.gz to your Palmetto storage

   Unpack the downloaded file and go into openbabel source folder

   ```
   $ tar -xvf openbabel-2.4.1.tar.gz
   $ cd openbabel-2.4.1
   $ mkdir build
   $ cd build
   $ cmake ../openbabel-2.4.1 -DCMAKE_INSTALL_PREFIX=$HOME/applications/ -DLIB_INSTALL_DIR=$HOME/applications/lib -DEIGEN3_INCLUDE_DIR=$HOME/applications/include/eigen3 -DBUILD_GUI=ON ..
   $ make -j4
   $ make test #make sure that all tests should be passed
   $ make install
   ```

1. The **obabel** executable file will be created in the installation folder:
   _/home/username/applications/bin_. Make sure you set the correct environment
   PATH in ~/.bashrc file

   ```
   export PATH=$PATH:$HOME/applications/bin
   ```
