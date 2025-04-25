## MrBayes

_MrBayes_ is a program for Bayesian inference and model choice across a wide
range of phylogenetic and evolutionary models. MrBayes uses Markov chain Monte
Carlo (MCMC) methods to estimate the posterior distribution of model parameters.

### Installing BEAGLE Library

**BEAGLE** library is supported to dramatic speedups for codon and amino acid
models on compatible hardware (NVIDIA graphics cards); To install MrBayes in
your `/home` directory on Palmetto, you'll need to begin by installing the
BEAGLE library. Here are the steps, starting with checking-out the source code
using Subversion:

    [galen@login001 ~]$ cd
    [galen@login001 ~]$ svn checkout http://beagle-lib.googlecode.com/svn/trunk/ beagle-setup
    [galen@login001 ~]$ cd beagle-setup
    [galen@login001 beagle-setup]$ ./autogen.sh
    [galen@login001 beagle-setup]$ ./configure --prefix=/home/galen/beagle-lib
    [galen@login001 beagle-setup]$ make install

Once installed, I also needed to add the location of these new libraries to my
`LD_LIBRARY_PATH` (this can be done in your `~/.bashrc` file, or in your PBS job
script as I have done at the bottom of this section):

    [galen@login001 beagle-setup]$ export LD_LIBRARY_PATH=/home/galen/beagle-lib/lib:$LD_LIBRARY_PATH

Finally, verify that everything is setup properly:

    [galen@login001 beagle-setup]$ make check

### Installing MrBayes

You can build a parallel version of MrBayes using OpenMPI or MPICH2. I used
MPICH2 and I included the BEAGLE libraries when compiling MrBayes, so those
libraries will also be needed whenever I run MrBayes.

    [galen@login001 src]$ module add gcc/4.4 mpich2/1.4

    [galen@login001 ~]$ wget http://downloads.sourceforge.net/project/mrbayes/mrbayes/3.2.1/mrbayes-3.2.1.tar.gz
    [galen@login001 ~]$ tar -zxf mrbayes-3.2.1.tar.gz
    [galen@login001 ~]$ cd mrbayes_3.2.1/src
    [galen@login001 src]$ export PKG_CONFIG_PATH=/home/galen/beagle-lib/lib/pkgconfig:$PKG_CONFIG_PATH
    [galen@login001 src]$ autoconf
    [galen@login001 src]$ ./configure --enable-mpi=yes --with-beagle=/home/galen/beagle-lib
    [galen@login001 src]$ make

Here, the `mb` executable was created in my `/home/galen/mrbayes_3.2.1/src`
directory.

### Running MrBayes

When running MrBayes in parallel, you'll need to use 1 processor core for each
Markov chain, and the default number of chains is 4 (3 heated and 1 that's not
heated).

Below is an example MrBayes job that uses one of the example Nexus files
included with my installation package
`/home/galen/mrbayes_3.2.1/examples/primates.nex`.

My MrBayes input file (mb_input) contains these commands:

    begin mrbayes;
      set autoclose=yes nowarn=yes;
      execute primates.nex;
      lset nst=6 rates=gamma;
      mcmc nruns=1 ngen=10000 samplefreq=10 file=primates.nex;
      mcmc file=primates.nex2;
      mcmc file=primates.nex3;
    end;

My PBS job script for running this job in parallel looks like this:

```
#!/bin/bash
#PBS -N MrBayes
#PBS -l select=1:ncpus=4:mpiprocs=4:mem=6gb:interconnect=1g,walltime=02:00:00
#PBS -j oe

source /etc/profile.d/modules.sh
module purge
module add gcc/4.4 mpich2/1.4

export LD_LIBRARY_PATH=/home/galen/beagle-lib/lib:$LD_LIBRARY_PATH
NCORES=`qstat -xf $PBS_JOBID | grep List.ncpus | sed 's/^.\{26\}//'`
cd $PBS_O_WORKDIR

mpiexec -n $NCORES /home/galen/mrbayes_3.2.1/src/mb mb_input > mb.log
```
