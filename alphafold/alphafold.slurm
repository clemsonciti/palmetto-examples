#!/bin/bash

#SBATCH --job-name=alphafold
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --gpus-per-node=a100:1
#SBATCH --mem=160G
#SBATCH --time=72:0:0


cd $SLURM_SUBMIT_DIR
module load alphafold/2.3.2
source activate $ALPHAFOLD_ENV

export APPTAINER_CACHEDIR=$TMPDIR

output_dir=$TMPDIR/output
mkdir -p $output_dir

python $ALPHAFOLD_DIR/singularity/run_singularity.py \
    --use_gpu \
    --output_dir=$output_dir \
    --data_dir=$ALPHAFOLD_DATASET \
    --fasta_paths="my.fasta" \
    --model_preset=monomer \
    --max_template_date=2020-05-1

mkdir $SLURM_SUBMIT_DIR/Output-$SLURM_JOB_ID
cp -R $output_dir $SLURM_SUBMIT_DIR/Output-$SLURM_JOB_ID
