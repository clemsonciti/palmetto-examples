## Running PyTorch in Distributed Data Parallel on Palmetto

This documentation is based the document at [Tampere University ITC](https://tuni-itc.github.io/wiki/Technical-Notes/Distributed_dataparallel_pytorch/). 


### Interactive

~~~
qsub -I -l select=2:ncpus=20:mem=120gb:ngpus=2:gpu_model=p100,walltime=24:00:00
~~~

~~~
python main_torch.py --nodes 2 --local_rank 1 --ngpus 2 --ip_address node0104 --data_path "/zfs/citi/datasets/mnist/" --epochs 10
~~~

### Batch