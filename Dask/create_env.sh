module load anaconda3/2022.10-gcc

# create the conda env
conda create -y -n dask anaconda python=3.11

# activate the env
source activate dask

# install python requirements
pip install -r requirements.txt

# install the jupyter kernel
ipykernel install --name dask --display-name "Dask (Py3.11)"