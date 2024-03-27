#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=10G
#SBATCH --cpus-per-task=2
#SBATCH --time=00:30:00

module load openjdk/17.0.8.1_1

./nextflow run 3_parallelExample.nf -c configs/slurm.config
