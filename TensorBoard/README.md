# Minimal Working Example for Running TensorBoard on the Palmetto Cluster

This README will guide you through running a minimal working example (MWE) of TensorBoard on the Palmetto Cluster. The steps include setting up the environment, running a training script, and visualizing the results using TensorBoard via OpenOnDemand.

### Prerequisites
- A Palmetto Cluster account.

### Step 1: Set Up Conda Environment

1. Create a new Conda environment named `TensorBoardExample` and activate it. To do this, in a terminal on Palmetto, run:
   ```bash
   module load miniforge3
   conda create -n TensorBoardExample python=3.12 -y
   source activate TensorBoardExample
   ```

2. Copy the contents of this repository (`tensorboard_mwe.py`, `run_tensorboard_mwe.sh`, and `requirements.txt`) to a directory in your storage space on Palmetto.

3. Install the required Python packages by running:
   ```bash
   pip install -r requirements.txt
   ```

### Step 2: Modify the Slurm Script

1. Modify the `run_tensorboard_mwe.sh` script to include the correct path to your `tensorboard_mwe.py` file. Update the line:
   ```bash
   python /path/to/your/tensorboard_mwe.py
   ```
   Replace `/path/to/your/tensorboard_mwe.py` with the actual path where your script is located.

### Step 3: Submit the Job

1. Submit the job using Slurm. In a terminal on Palmetto, run:
   ```bash
   sbatch run_tensorboard_mwe.sh
   ```

2. Wait for the job to run. The output will be saved, and training logs will be generated in the specified log directory (e.g., `/scratch/[your_username]/tensorboard_logs`).

### Step 4: Launch TensorBoard via OpenOnDemand

1. Start a Jupyter session through OpenOnDemand.

2. Once Jupyter is running, open a terminal within JupyterLab.

3. Determine the compute node on which your Slurm job ran by checking the job output, the JupyterLab url, or by using the Slurm command:
   ```bash
   squeue -u your_username
   ```
   Note the node name, which will probably look something like `nodeXXXX`.

4. Start TensorBoard on that node using the following command in the terminal:
   ```bash
   tensorboard --logdir=/scratch/[your_username]/tensorboard_logs --port=8888 --bind_all --path_prefix=/node/[node_name].palmetto.clemson.edu/8888
   ```
   Make sure to update the username ('[your_username']) and the node name (`[node_name]`) with your actual username and the node where your JupyterLab job ran.

### Step 5: Access TensorBoard in Your Browser

1. Open a new browser tab and navigate to the URL:
   ```https://ondemand.rcd.clemson.edu/node/[node_name].palmetto.clemson.edu/8888/```

Replace `[node_name]` with the correct node name from Step 4.

2. You should now be able to view the TensorBoard dashboard and see the logs from your training run.

### Troubleshooting
- If you encounter a `404 Not Found` error, make sure that the node name and port number are correctly updated in the command and the URL.
- If TensorBoard shows errors related to CUDA, they can often be ignored if you are (intentionally) running on a CPU-only node.

### Summary
By following these steps, you can run a minimal example of TensorBoard on the Palmetto Cluster.

