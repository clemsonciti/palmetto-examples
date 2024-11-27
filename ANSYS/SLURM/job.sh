#!/bin/bash
#SBATCH --job-name=ansys
#SBATCH --nodes=2
#SBATCH --tasks-per-node=2
#SBATCH --mem=24G
#SBATCH --time=1:0:0

module purge
module load ansys

cd $SLURM_SUBMIT_DIR

SCRATCH=$SLURM_SUBMIT_DIR

rm host.list*
rm HOSTNAME

srun hostname > HOSTNAME
machines=$(uniq -c HOSTNAME | awk '{print $2":"$1}' | tr '\n' :)
machines=${machines::-1}

ansys232 \
    -mpi openmpi \
    -dir "$SCRATCH" \
    -j EXAMPLE \
    -s read -l en-us -b \
    -i input.txt -o output.txt \
    -dis -machines "$machines"
