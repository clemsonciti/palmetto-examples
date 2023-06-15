#!/bin/bash
MASTER_HOSTNAME=$1
PROJECT_DIR=$2
NNODES=$3
NGPUS_PER_NODE=$4
EPOCHS=$5

cd $PROJECT_DIR
source /etc/profile.d/modules.sh
module load anaconda3/2022.05-gcc/9.5.0
source activate pytorch
torchrun \
    --nnodes=$NNODES \
    --nproc_per_node=$NGPUS_PER_NODE \
    --rdzv_id=12345 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$MASTER_HOSTNAME:3000 \
    train.py --ddp --epochs $EPOCHS

echo "$HOSTNAME" finished tasks