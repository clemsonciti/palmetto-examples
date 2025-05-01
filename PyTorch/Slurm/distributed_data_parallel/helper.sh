#!/bin/bash
MASTER_HOSTNAME=$1
PROJECT_DIR=$2
NNODES=$3
NGPUS_PER_NODE=$4
EPOCHS=$5

cd $PROJECT_DIR
module load anaconda3
source activate PytorchDDPExample
torchrun \
    --nnodes=$NNODES \
    --nproc_per_node=$NGPUS_PER_NODE \
    --rdzv_id=12345 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$MASTER_HOSTNAME:3000 \
    train.py --ddp --epochs $EPOCHS

echo "$HOSTNAME" finished tasks
