# Palmetto as a High-Performance AI Cluster: Imagenet Training

## Purpose
This example demonstrates large-scale Palmetto training of [ResNet50](https://arxiv.org/abs/1512.03385) on the [ImageNet-1000](https://image-net.org/download.php) task. We will use the ImageNet training script created by Ross Wightman as part of the [Pytorch Image Models (TIMM)](https://github.com/huggingface/pytorch-image-models) library. We have saved a local copy of TIMM into this example folder for reproducibility. This example is built around the [`train.py`](pytorch-image-models/train.py) script. We will demonstrate how training time can be dramatically reduced by scaling to multiple GPUs and multiple nodes.

## Palmetto Cluster Setup
Clone this repo or copy the contents into a new directory on Palmetto. We will refer to the location of this directory as `<project_dir>` for the remainder of the tutorial. Wherever you see `<project_dir>`, replace it with the actual path to your project directory.

Request an interactive compute job and create a conda environment.
```bash
# from the login node:
qsub -I -l select=1:ncpus=4:mem=8gb,walltime=1:00:00
# wait for interactive job shell...

# ... in job shell:
cd <project_dir>
module load anaconda3/2022.05-gcc/9.5.0
conda env create --file environment.yml  # creates a conda environment called "pytorch"

# terminate the job
exit
```

## Running in non-distributed mode
You can run the training script in non-distributed mode. This can be useful to test your setup and establish a timing baseline.
```bash
# Resource request. Tweak as needed for your custom script.
qsub -I -l select=1:ncpus=25:mem=125gb:ngpus=1:gpu_model=a100:phase=29,walltime=1:00:00
# wait for interactive job shell...

# ... in job shell:
cd <project_dir>
module load anaconda3/2022.05-gcc/9.5.0
source activate pytorch

# location where imagenet data is stored
export DATA_DIR='/project/rcde/datasets/imagenet/ILSVRC/Data/CLS-LOC'

time python pytorch-image-models/train.py \
        --model resnet50d \
        --epochs 1 \
        --warmup-epochs 0 \
        --lr 0.4 \
        --batch-size 256 \
        --sched none \
        --amp \
        -j 10 \
        $DATA_DIR

# end the job
exit
```
The `time` command outputs three numbers. The number labeled `real` records the total walltime from start to finish. Our test with a single a100 GPU had a total execution time 20 minutes and 18 seconds. At peak, training proceeded at a rate of 1,150 images/second. Assuming this peak performance, a 200-epoch training run would take about 2 days.

## Distributed training
We can use Pytorch's `torchrun` command-line tool to distribute training over multiple GPUs on multiple nodes. See the included `distributed_helper.sh` script for implementation and our [Distributed Data Parallel example](../distributed_data_parallel/README.md) for a more step-by-step example. 
```bash
# Resource request. Tweak as needed for your custom script.

#################################################################################
# NOTE: this is a very large resource request to demonstrate the power of Palmetto. 
# Many use cases do not need such large requests. Please do not request this many
# resources unless you are sure that you need them. Jobs requesting GPU nodes and 
# not using them will be deleted without notice. If you have questions, reach
# out to the RCDE team by submitting a ticket to ithelp. 
#################################################################################
qsub -I -l select=20:ncpus=50:mem=250gb:ngpus=2:gpu_model=a100:phase=28,walltime=0:20:00
# wait for interactive job shell...

# ... in job shell:
cd <project_dir>

num_nodes=`cat $PBS_NODEFILE | wc -l`
num_gpus_per_node=`nvidia-smi --query-gpu=name --format=csv,noheader | wc -l`
data_dir='/project/rcde/datasets/imagenet/ILSVRC/Data/CLS-LOC'

time pbsdsh -- bash "$(pwd)"/distributed_helper.sh $HOSTNAME $(pwd) $num_nodes $num_gpus_per_node $data_dir
                                                                
# end the job
exit

```
In our test on 20 nodes, 40 a100 GPUs, execution took about 1.5 minutes with much of that time spend in setup rather than training. At peak, training proceeded at a rate of 47,000 images/second -- roughly 40 times faster than than the single-gpu rate. At this rate, a 200-epoch training run would take 1.2 hours.