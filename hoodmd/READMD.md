## HOOMD
  
### Run HOOMD
Now the HOOMD-BLUE v2.3.5 has been installed. Create a simple python file “test_hoomd.py” to run HOOMD 

```
import hoomd
import hoomd.md
hoomd.context.initialize("");
hoomd.init.create_lattice(unitcell=hoomd.lattice.sc(a=2.0), n=5);
nl = hoomd.md.nlist.cell();
lj = hoomd.md.pair.lj(r_cut=2.5, nlist=nl);
lj.pair_coeff.set('A', 'A', epsilon=1.0, sigma=1.0);
hoomd.md.integrate.mode_standard(dt=0.005);
all = hoomd.group.all();
hoomd.md.integrate.langevin(group=all, kT=0.2, seed=42);hoomd.analyze.log(filename="log-output.log",
                  quantities=['potential_energy', 'temperature'],
                  period=100,
                  overwrite=True);
hoomd.dump.gsd("trajectory.gsd", period=2e3, group=all, overwrite=True);
hoomd.run(1e4);
```

If you have logged out of the node, request an interactive session on a GPU node and add required modules:

```
$ qsub -I -l select=1:ncpus=16:mem=64gb:ngpus=2:gpu_model=p100:mpiprocs=16:interconnect=fdr,walltime=2:00:00
$ module add anaconda3/5.1.0 gcc/5.4.0 cuda-toolkit/9.0.176
```

Run the script interactively:

```
$ python test_hoomd.py
```


Alternatively, you can setup a PBS job script to run HOOMD in batch mode. A sample is below for *Test_Hoomd.sh*:


```
#PBS -N HOOMD
#PBS -l select=1:ncpus=16:mem=64gb:ngpus=2:gpu_model=p100:mpiprocs=16:interconnect=fdr,walltime=02:00:00
#PBS -j oe

module purge
module add anaconda3/5.1.0 gcc/5.4.0 cuda-toolkit/9.0.176

cd $PBS_O_WORKDIR
python test_hoomd.py
```

Submit the job:

```
$ qsub Test_Hoomd.sh
```

This is it.
