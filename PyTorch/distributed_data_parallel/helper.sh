#!/bin/bash

source /etc/profile.d/modules.sh
module load anaconda3/2022.05-gcc/9.5.0 cuda/11.6.2-gcc/9.5.0 cudnn/8.1.0.77-11.2-gcc/9.5.0
source activate parallel
cd "$2" || exit
torchrun --nnodes=2 --nproc_per_node=2 --rdzv_id=12345 --rdzv_backend=c10d --rdzv_endpoint="$1":3001  "$3" -e 200 -p multi_node_snapshot.pth
echo "$HOSTNAME" finished tasks