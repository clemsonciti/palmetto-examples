#!/bin/bash

#./run_torch.sh $PBS_O_WORKDIR {} $master_ip $data_path $count

cd $1
partition=$(($2 - 1))

# loading modules and environment based on the PyTorch 
# installation guide. 

module load anaconda3/2019.10-gcc/8.3.1
module load cudnn/8.0.4.30-11.1-linux-x64-gcc/8.4.1 
module load cuda/11.1.0-gcc/8.3.1
source activate pytorch

export LD_PRELOAD=/usr/lib64/libcrypto.so.1.1:$LD_PRELOAD

set -x 
python main_torch.py --nodes $5 --local_rank ${partition} --ngpus 2 --ip_address $3 --data_path $4 --epochs 10
