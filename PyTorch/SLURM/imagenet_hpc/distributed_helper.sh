#!/bin/bash
MASTER_HOSTNAME=$1
PROJECT_DIR=$2
NNODES=$3
NGPUS_PER_NODE=$4
DATA_DIR=$5

echo "--------------------------------------------------------"
echo "Starting distributed job with the following arguments:"
echo "    Head node host: "$MASTER_HOSTNAME
echo "    Project directory: "$PROJECT_DIR
echo "    Number of nodes: "$NNODES
echo "    Number of gpus per node: "$NGPUS_PER_NODE
echo "    Imagenet data directory: "$DATA_DIR
echo "--------------------------------------------------------"

cd $PROJECT_DIR"/pytorch-image-models"
source /etc/profile.d/modules.sh
module load anaconda3/2022.05-gcc/9.5.0
source activate pytorch
torchrun \
    --nnodes=$NNODES \
    --nproc_per_node=$NGPUS_PER_NODE \
    --rdzv_id=12345 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$MASTER_HOSTNAME:3000 \
    train.py \
        --model resnet50d \
        --epochs 1 \
        --warmup-epochs 0 \
        --lr 0.4 \
        --batch-size 256 \
        --sched none \
        --amp \
        -j 10 \
        $DATA_DIR

echo "$HOSTNAME" finished tasks