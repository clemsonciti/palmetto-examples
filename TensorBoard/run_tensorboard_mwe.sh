#!/bin/bash
#SBATCH --job-name=tensorboard_mwe
#SBATCH --output=tensorboard_mwe.out
#SBATCH --error=tensorboard_mwe.err
#SBATCH --partition=work1
#SBATCH --time=00:05:00
#SBATCH --mem=4G

module load miniforge3

source activate TensorBoardExample # Replace with your conda environment name

python /path/to/your/tensorboard_mwe.py
