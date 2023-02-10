---
title: Trinity
keywords: [trinity]
sidebar: documentation_sidebar
permalink: software_trinity.html
---

[Trinity](http://trinityrnaseq.sourceforge.net/) represents a novel method for
the efficient and robust de novo reconstruction of transcriptomes from RNA-seq
data. Trinity combines three independent software modules: Inchworm, Chrysalis,
and Butterfly, applied sequentially to process large volumes of RNA-seq reads.
Trinity partitions the sequence data into many individual de Bruijn graphs, each
representing the transcriptional complexity at at a given gene or locus, and
then processes each graph independently to extract full-length splicing isoforms
and to tease apart transcripts derived from paralogous genes.

## Download Trinity

```bash
wget http://downloads.sourceforge.net/project/trinityrnaseq/trinityrnaseq_r20131110.tgz
tar -zxf trinityrnaseq_r20131110.tgz
cd trinityrnaseq_r20131110
```

## Build/compile Trinity

You can build/compile Trinity by simply running make in the installation
directory. This should build Inchworm and Chrysalis, both written in C++.
Butterfly should not require any special compilation, as its written in Java and
provided as portable precompiled software.

```bash
module add gcc/4.8.1
make
```

You'll also need to install Bowtie (version 1, not Bowtie2) for running Trinity,

```bash
wget http://downloads.sourceforge.net/project/bowtie-bio/bowtie/1.0.0/bowtie-1.0.0-src.zip
unzip bowtie-1.0.0-src.zip
cd bowtie-1.0.0
module add gcc/4.8.1
make
```

...and you may also need to install SAMtools,

```bash
wget http://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2
tar -jxf samtools-0.1.19.tar.bz2
cd samtools-0.1.19
module add gcc/4.8.1
make
```

## Running Trinity

A complete Trinity job runs in a series of stages, so you can run Trinity as a
single job or as a series of jobs. The specific settings you choose when running
your Trinity job can vary so please review the Trinity documentation
<http://trinityrnaseq.sourceforge.net/#running_trinity> to ensure that you've
chosen the appropriate settings for your job. The following are just examples
for running Trinity on Palmetto. There are a varitey of ways to do this.

For any Trinity job, the number of CPU cores and amount of memory you need will
vary depending on your job's needs. Please consult the Trinity documentation to
try to determine the appropriate hardware for your job.

For a complete, standalone Trinity job, the PBS job script may look something
like this:

```bash
#!/bin/bash
#PBS -N fasta2q
#PBS -l select=1:ncpus=16:mpiprocs=16:mem=62gb:ssd=true,walltime=72:00:00
#PBS -j oe

source /etc/profile.d/modules.sh
module purge
module add gcc/4.8.1

cd $PBS_O_WORKDIR

mkdir -p /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinityrnaseq_r20131110 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/bowtie-1.0.0 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/samtools-0.1.19 /local_scratch/pbs.${PBS_JOBID}

export PATH=/local_scratch/pbs.${PBS_JOBID}/samtools-0.1.19:$PATH
export PATH=/local_scratch/pbs.${PBS_JOBID}/bowtie-1.0.0:$PATH

cp /home/galen/job1/XXTL.fasta /home/galen/job1/XXTR.fasta /local_scratch/pbs.${PBS_JOBID}
/local_scratch/pbs.${PBS_JOBID}/trinityrnaseq_r20131110/Trinity.pl --seqType fa --JM 60G --left XXTL.fasta --right XXTR.fasta --output /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir --CPU 16 --inchworm_cpu 16 --min_kmer_cov 2

cp -r /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir /home/galen/job1
rm -rf /local_scratch/pbs.${PBS_JOBID}/*
```

If you choose to break-up your Trinity stages into separate jobs, those
individual stage job scripts may look something like these (below). Note: the
last option for the `Trinity.pl` command in each stage (colored red, below) is
how you will instruct Trinity to complete only the current stage. The
`Trinity.pl` script will check to see where the previous job ended and it will
resume processing tasks from that point.

Trinity **stage 1**, generate the kmer-catalog and run Inchworm,

```bash
#!/bin/bash
#PBS -N Tstage1
#PBS -l select=1:ncpus=16:mpiprocs=16:mem=62gb:ssd=true,walltime=72:00:00
#PBS -j oe

source /etc/profile.d/modules.sh
module purge
module add gcc/4.8.1

cd $PBS_O_WORKDIR

mkdir -p /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinityrnaseq_r20131110 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/bowtie-1.0.0 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/samtools-0.1.19 /local_scratch/pbs.${PBS_JOBID}

export PATH=/local_scratch/pbs.${PBS_JOBID}/samtools-0.1.19:$PATH
export PATH=/local_scratch/pbs.${PBS_JOBID}/bowtie-1.0.0:$PATH

cp /home/galen/job1/XXTL.fasta /home/galen/job1/XXTR.fasta /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinity_out_dir /local_scratch/pbs.${PBS_JOBID}
/local_scratch/pbs.${PBS_JOBID}/trinityrnaseq_r20131110/Trinity.pl --seqType fa --JM 60G --left XXTL.fasta --right XXTR.fasta --output /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir --CPU 16 --inchworm_cpu 16 --min_kmer_cov 2 --no_run_chrysalis

cp -r /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir /home/galen/job1
rm -rf /local_scratch/pbs.${PBS_JOBID}/*
```

Trinity **stage 2**, Chrysalis clustering of inchworm contigs and mapping reads,

```bash
#!/bin/bash
#PBS -N Tstage2
#PBS -l select=1:ncpus=16:mpiprocs=16:mem=62gb:ssd=true,walltime=72:00:00
#PBS -j oe

source /etc/profile.d/modules.sh
module purge
module add gcc/4.8.1

cd $PBS_O_WORKDIR

mkdir -p /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinityrnaseq_r20131110 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/bowtie-1.0.0 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/samtools-0.1.19 /local_scratch/pbs.${PBS_JOBID}

export PATH=/local_scratch/pbs.${PBS_JOBID}/samtools-0.1.19:$PATH
export PATH=/local_scratch/pbs.${PBS_JOBID}/bowtie-1.0.0:$PATH

cp /home/galen/job1/XXTL.fasta /home/galen/job1/XXTR.fasta /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinity_out_dir /local_scratch/pbs.${PBS_JOBID}
/local_scratch/pbs.${PBS_JOBID}/trinityrnaseq_r20131110/Trinity.pl --seqType fa --JM 60G --left XXTL.fasta --right XXTR.fasta --output /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir --CPU 16 --inchworm_cpu 16 --min_kmer_cov 2 --no_run_quantifygraph

cp -r /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir /home/galen/job1
rm -rf /local_scratch/pbs.${PBS_JOBID}/*
```

Trinity **stage 3**, Chrysalis deBruijn graph construction,

```bash
#!/bin/bash
#PBS -N Tstage1
#PBS -l select=1:ncpus=16:mpiprocs=16:mem=62gb:ssd=true,walltime=72:00:00
#PBS -j oe

source /etc/profile.d/modules.sh
module purge
module add gcc/4.8.1

cd $PBS_O_WORKDIR
mkdir -p /local_scratch/pbs.${PBS_JOBID}

cp -r /home/galen/trinityrnaseq_r20131110 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/bowtie-1.0.0 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/samtools-0.1.19 /local_scratch/pbs.${PBS_JOBID}

export PATH=/local_scratch/pbs.${PBS_JOBID}/samtools-0.1.19:$PATH
export PATH=/local_scratch/pbs.${PBS_JOBID}/bowtie-1.0.0:$PATH

cp /home/galen/job1/XXTL.fasta /home/galen/job1/XXTR.fasta /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinity_out_dir /local_scratch/pbs.${PBS_JOBID}
/local_scratch/pbs.${PBS_JOBID}/trinityrnaseq_r20131110/Trinity.pl --seqType fa --JM 60G --left XXTL.fasta --right XXTR.fasta --output /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir --CPU 16 --inchworm_cpu 16 --min_kmer_cov 2 --no_run_butterfly

cp -r /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir /home/galen/job1
rm -rf /local_scratch/pbs.${PBS_JOBID}/*
```

Trinity stage 4, run Butterfly and generate the final Trinity.fasta file,

```bash
#!/bin/bash
#PBS -N Tstage1
#PBS -l select=1:ncpus=16:mpiprocs=16:mem=62gb:ssd=true,walltime=72:00:00
#PBS -j oe

source /etc/profile.d/modules.sh
module purge
module add gcc/4.8.1

cd $PBS_O_WORKDIR
mkdir -p /local_scratch/pbs.${PBS_JOBID}

cp -r /home/galen/trinityrnaseq_r20131110 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/bowtie-1.0.0 /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/samtools-0.1.19 /local_scratch/pbs.${PBS_JOBID}

export PATH=/local_scratch/pbs.${PBS_JOBID}/samtools-0.1.19:$PATH
export PATH=/local_scratch/pbs.${PBS_JOBID}/bowtie-1.0.0:$PATH

cp /home/galen/job1/XXTL.fasta /home/galen/job1/XXTR.fasta /local_scratch/pbs.${PBS_JOBID}
cp -r /home/galen/trinity_out_dir /local_scratch/pbs.${PBS_JOBID}
/local_scratch/pbs.${PBS_JOBID}/trinityrnaseq_r20131110/Trinity.pl --seqType fa --JM 60G --left XXTL.fasta --right XXTR.fasta --output /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir --CPU 16 --inchworm_cpu 16 --min_kmer_cov 2 --bflyHeapSpaceMax 60G --bflyCPU 4

cp -r /local_scratch/pbs.${PBS_JOBID}/trinity_out_dir /home/galen/job1
rm -rf /local_scratch/pbs.${PBS_JOBID}/*
```
