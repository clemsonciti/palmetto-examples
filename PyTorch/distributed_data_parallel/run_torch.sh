#!/bin/bash

#./run_torch.sh $PBS_O_WORKDIR {} $master_ip $data_path $count

cd $1
partition=$(($2 - 1))

module load anaconda3/2019.10-gcc/8.3.1

set -x 
python main_torch.py --nodes $5 --local_rank ${partition} --ngpus 2 --ip_address $3 --data_path $4 --epochs 10 >> torch.${partition}
