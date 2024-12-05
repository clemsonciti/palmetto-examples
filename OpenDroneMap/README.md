# Open Drone Map

Open Drone Map (ODM) can be run on a single Palmetto2 node with Apptainer.
For certain stages of the pipeline, a GPU can speed up execution.
Since the operation only uses the GPU for a short time, please request a GPU that is less in demand, such as the K20, K40, or P100 GPU.
 
## Run ODM interactively

For small processing jobs, you can run ODM in an interactive job.
The `salloc` command below will request 16 CPU cores, 60GB of memory and 1 GPU for 2 hours. The placement of the jobs will be limited to nodes with K20, K40, or P100 GPUs.
```bash
salloc -n1 -c16 --mem=60G --gpus=1 -t 2:00:00 -C "gpu_k20|gpu_k40|gpu_p100"
```

For this example, we will be downloading an example dataset from https://github.com/OpenDroneMap/odm_data_waterbury.git. The images in this project contain GPS coordinates to be used by ODM.

Setup the ODM directory structure like the following:
```bash
mkdir /scratch/$USER/odm
cd /scratch/$USER/odm
git clone https://github.com/OpenDroneMap/odm_data_waterbury.git
```
When running ODM, it will assume the images are located in `datasets_dir/project_name/images/` where `datasets_dir`in this case is `/scratch/$USER/odm`.

Finally we can start the processing. Use Apptainer to launch the program.
```bash
apptainer run -B /scratch/$USER/odm/:/datasets --nv docker://opendronemap/odm:gpu --project-path /datasets odm_data_waterbury --max-concurrency $SLURM_CPUS_ON_NODE
```

In the above command, we mount `/scratch/$USER/odm` to `/datasets` inside the container. This step is completely optional as you can specify the `--project-path` argument to ODM to whatever your directory is.
We also use the `opendronemap/odm:gpu` container image since we requested a GPU. If not using a GPU, use the `opendronemap/odm:latest` container image.
Finally, the `--max-concurrency` flag passed to ODM is set to `$SLURM_CPUS_ON_NODE`. This is needed to limit ODM to only using the number of threads as CPUs requested for the job. In the above example, `$SLURM_CPUS_ON_NODE` would be **16**.