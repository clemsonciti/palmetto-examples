## mothur

This page instructs how to install mothur software to Palmetto The code and the
issue tracker can be found
[here](https://github.com/mothur/mothur/blob/master/INSTALL.md)

1. Request an interactive session. For example:

   ```
   $ qsub -I -l select=1:ncpus=6:mem=24gb:interconnect=fdr,walltime=3:00:00
   ```

2. Load the required modules

   ```
   $ module load boost/1.65.1 hdf5/1.10.1 openmpi/1.10.3 gcc/8.2.0
   ```

3. Download mothur from
   [source](https://github.com/mothur/mothur/releases/tag/v1.41.3). Here we
   download the latest version 1.41.3

   ```
   $ wget https://github.com/mothur/mothur/archive/v1.41.3.tar.gz
   ```

4. Unpack the downloaded file and go into mothur source folder

   ```
   $ tar -xvf v1.41.3.tar.gz
   $ cd mothur-1.41.3
   ```

5. Modify the Makefile

   ```
   $ nano Makefile
   #Replace the following lines 22-32 with information: (Note: username should be replaced)
    OPTIMIZE ?= yes
    USEREADLINE ?= yes
    USEBOOST ?= yes
    USEHDF5 ?= yes
    LOGFILE_NAME ?= no
    BOOST_LIBRARY_DIR ?= "/software/boost/1.65.1/lib"
    BOOST_INCLUDE_DIR ?= "/software/boost/1.65.1/include"
    HDF5_LIBRARY_DIR ?= "/software/hdf5/1.10.1/lib"
    HDF5_INCLUDE_DIR ?= "/software/hdf5/1.10.1/include"
    MOTHUR_FILES ?= "\"home/username/application/bin/mothur\""
    VERSION = "\"1.41.3\""
   ```

6. Run make file

   ```
   $ make
   ```

7. The _mothur_ executable file will be created in the installation folder:
   **/home/username/applications/bin**. Make sure you set the correct
   environment PATH in ~/.bashrc file

   ```
   export PATH=$PATH:$HOME/applications/bin
   ```
