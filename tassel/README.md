---
title: Tassel
keywords: [tassel]
sidebar: documentation_sidebar
permalink: software_tassel.html
---

[TASSEL](http://www.maizegenetics.net/index.php?option=com_content&task=view&id=89&Itemid=119)
(Trait Analysis by Association, Evolution, and Linkage) is a software package
used to evaluate genotype and trait associations with the tools of population
and quantitative genetics. TASSEL can handle datasets commonly encountered in
the plant community, e.g. replicated trials, inbred lines, and complex
structured pedigrees.

## Downloading/installing TASSEL 3

Verify your Java version to ensure that you're downloading the correct version
of TASSEL (TASSEL 3 is used with Java version 6, TASSEL 4 is used with Java
version 7):

    [galen@login001 ~]$ java -version
    java version "1.6.0_11"
    Java(TM) SE Runtime Environment (build 1.6.0_11-b03)
    Java HotSpot(TM) 64-Bit Server VM (build 11.0-b16, mixed mode)

Download the latest build of TASSEL using Git:

    [galen@login001 ~]$ git --version
    git version 1.7.1

    [galen@login001 ~]$ git clone git://git.code.sf.net/p/tassel/tassel3-standalone
    Initialized empty Git repository in /home/galen/tassel/tassel3-standalone/.git/
    remote: Counting objects: 293, done.
    remote: Compressing objects: 100% (290/290), done.
    remote: Total 293 (delta 114), reused 0 (delta 0)
    Receiving objects: 100% (293/293), 42.95 MiB | 1.86 MiB/s, done.
    Resolving deltas: 100% (114/114), done.

## Running TASSEL 3 (using the GUI)

`-Xms` is used to set the lower bound for the total heap size, `-Xmx` is used to
set the upper bound.

An incorrectly sized Java heap can lead to OutOfMemoryError exceptions or to a
reduction in the performance of the Java application. If the Java heap is
smaller than the memory requirements of the application, OutOfMemoryError
exceptions are generated because of Java heap exhaustion. If the Java heap is
slightly larger than the requirements of the application, garbage collection
runs very frequently and affects the performance of the application. Size your
Java heap so that your application runs with a minimum heap usage of 40%, and a
maximum heap usage of 70%.

Of course, you'll have to enable X11 tunneling to display the GUI. See details
presented here.

    [galen@login001 ~]$ qsub -I -X -l select=1:ncpus=1:mem=11gb
    qsub (Warning): Interactive jobs will be treated as not rerunnable
    qsub: waiting for job 6360074.pbs01 to start
    qsub: job 6360074.pbs01 ready

    [galen@node0133 ~]$ export PATH=/home/galen/tassel3-standalone:$PATH
    [galen@node0133 ~]$ cd tassel3-standalone/
    [galen@node0133 tassel3-standalone]$ ./start_tassel.pl -Xms512m -Xmx10g

## Running TASSEL 3 (from the command line)

Please review the user guide for running Tassel 3 from the command line. It's
available here: <http://www.maizegenetics.net/tassel/docs/TasselPipelineCLI.pdf>

See note about heap size settings, above.

    [galen@login001 ~]$ qsub -I -l select=1:ncpus=1:mem=11gb
    qsub (Warning): Interactive jobs will be treated as not rerunnable
    qsub: waiting for job 6360074.pbs01 to start
    qsub: job 6360074.pbs01 ready

    [galen@node0133 ~]$ export PATH=/home/galen/tassel3-standalone:$PATH
    [galen@node0133 ~]$ cd tassel3-standalone/
    [galen@node0133 tassel3-standalone]$ ./run_pipeline.pl -Xms512m -Xmx10g ./run_pipeline.pl -fork1 -h my_hapmap_file.txt -ld -ldd png -o my_output_file.png -runfork1

Below is a simple example of a TASSEL 3 PBS job script:

```bash
#!/bin/bash
#PBS -N TAS-TEST
#PBS -l select=1:ncpus=1:mem=11gb,walltime=12:00:00
#PBS -j oe

cd $PBS_O_WORKDIR
export PATH=/home/galen/tassel3-standalone:$PATH

./run_pipeline.pl -Xms512m -Xmx10g ./run_pipeline.pl -fork1 \
-h my_hapmap_file.txt -ld -ldd png -o my_output_file.png -runfork1
```

#### Updating TASSEL 3

Updating your TASSEL 3 installation to the latest version is easy. Simply enter
the TASSEL 3 installation directory and run `git pull`

    [galen@login001 ~]$ cd tassel3-standalone
    [galen@login001 tassel3-standalone]$ git pull

## Downloading/installing TASSEL 4

Verify your Java version to ensure that you're downloading the correct version
of TASSEL (TASSEL 3 is used with Java version 6, TASSEL 4 is used with Java
version 7). To install your own build (version) of Java, see the instructions
presented here.

    [galen@login001 ~]$ java -version
    java version "1.7.0_45"
    Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
    Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

Download the latest build of TASSEL using Git:

    [galen@login001 ~]$ git --version
    git version 1.7.1

    [galen@login001 ~]$ git clone git://git.code.sf.net/p/tassel/tassel4-standalone
    Initialized empty Git repository in /home/galen/tassel4-standalone/.git/
    remote: Counting objects: 361, done.
    remote: Compressing objects: 100% (358/358), done.
    remote: Total 361 (delta 176), reused 0 (delta 0)
    Receiving objects: 100% (361/361), 48.07 MiB | 3.83 MiB/s, done.
    Resolving deltas: 100% (176/176), done.

## Running TASSEL 4 (using the GUI)

`-Xms` is used to set the lower bound for the total heap size, `-Xmx` is used to
set the upper bound.

An incorrectly sized Java heap can lead to OutOfMemoryError exceptions or to a
reduction in the performance of the Java application. If the Java heap is
smaller than the memory requirements of the application, OutOfMemoryError
exceptions are generated because of Java heap exhaustion. If the Java heap is
slightly larger than the requirements of the application, garbage collection
runs very frequently and affects the performance of the application. Size your
Java heap so that your application runs with a minimum heap usage of 40%, and a
maximum heap usage of 70%.

Of course, you'll have to enable X11 tunneling to display the GUI. See details
presented here.

    [galen@login001 ~]$ qsub -I -X -l select=1:ncpus=1:mem=11gb
    qsub (Warning): Interactive jobs will be treated as not rerunnable
    qsub: waiting for job 6360074.pbs01 to start
    qsub: job 6360074.pbs01 ready

    [galen@node0133 ~]$ export PATH=/home/galen/tassel4-standalone:$PATH
    [galen@node0133 ~]$ cd tassel4-standalone/
    [galen@node0133 tassel4-standalone]$ ./start_tassel.pl -Xms512m -Xmx10g

## Running TASSEL 4 (from the command line)

Please review the user guide for running Tassel 4 from the command line. It's
available here: <http://www.maizegenetics.net/tassel/docs/TasselPipelineCLI.pdf>

See note about heap size settings, above.

    [galen@login001 ~]$ qsub -I -l select=1:ncpus=1:mem=11gb
    qsub (Warning): Interactive jobs will be treated as not rerunnable
    qsub: waiting for job 6360074.pbs01 to start
    qsub: job 6360074.pbs01 ready

    [galen@node0133 ~]$ export PATH=/home/galen/tassel4-standalone:$PATH
    [galen@node0133 ~]$ cd tassel4-standalone/
    [galen@node0133 tassel4-standalone]$ ./run_pipeline.pl -Xms512m -Xmx10g ./run_pipeline.pl -fork1 -h my_hapmap_file.txt -ld -ldd png -o my_output_file.png -runfork1

Below is a simple example of a TASSEL 4 PBS job script:

```bash
#!/bin/bash
#PBS -N TAS-TEST
#PBS -l select=1:ncpus=1:mem=11gb,walltime=12:00:00
#PBS -j oe

cd $PBS_O_WORKDIR
export PATH=/home/galen/tassel4-standalone:$PATH

./run_pipeline.pl -Xms512m -Xmx10g ./run_pipeline.pl -fork1 \
-h my_hapmap_file.txt -ld -ldd png -o my_output_file.png -runfork1
```

## Updating TASSEL 4

Updating your TASSEL 4 installation to the latest version is easy. Simply enter
the TASSEL 4 installation directory and run `git pull`

    [galen@login001 ~]$ cd tassel4-standalone
    [galen@login001 tassel4-standalone]$ git pull
