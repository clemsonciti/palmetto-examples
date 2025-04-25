## MrBayes

_MrBayes_ is a program for Bayesian inference and model choice across a wide
range of phylogenetic and evolutionary models. MrBayes uses Markov chain Monte
Carlo (MCMC) methods to estimate the posterior distribution of model parameters.

### Installing using Spack

You can install MrBayes through [Spack](https://docs.rcd.clemson.edu/palmetto/software/install/#self-installation-via-spack). To do so, request a compute node, load spack, and request MrBayes:

```sh
salloc -c 2 --mem 8gb --time 1:00:00
module load spack
spack install mrbayes
```

Spack will install the package and any dependencies in your home directory.

### Running MrBayes

To run MrBayes installed through Spack within a job, you will need to load Spack, then have Spack load MrBayes:

```sh
module load spack
spack load mrbayes
```

MrBayes is now available as the `mb` command.

As an example, we can build a batch script to analyze sample data.
Create a MrBayes input file (mb_input) with these commands:

```text
begin mrbayes;
  set autoclose=yes nowarn=yes;
  execute primates.nex;
  lset nst=6 rates=gamma;
  mcmc nruns=1 ngen=1000000 samplefreq=10 file=primates.nex;
end;
```

Download the example data:

```sh
curl -LfO https://raw.githubusercontent.com/NBISweden/MrBayes/refs/heads/develop/examples/primates.nex
```

Then the following batch script should enable this analysis:

```sh
#!/bin/bash
#SCRATCH --nodes 1
#SCRATCH --ntasks 4
#SCRATCH --time 2:00:00
#SCRATCH --mem 6gb

module load spack
spack load mrbayes

UCX_TLS=self,sm srun mb mb_input
```
