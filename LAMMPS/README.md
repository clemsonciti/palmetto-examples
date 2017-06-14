# LAMMPS

To run this example, you will need to compile LAMMPS with support for CUDA and KOKKOS.
Instructions for doing this are available
[here](#). You will also need to copy the produced executable
`lmp_palmetto_kokkos_cuda_openmpi` to the working directory.
The files included are the LAMMPS input file `in.lj`,
and the batch script `job.sh`.

To submit the job:

~~~
$ qsub job.sh
~~~

After job completion, the expected output in `log.lammps`
is provided below:

~~~
LAMMPS (17 Nov 2016)
KOKKOS mode is enabled (../kokkos.cpp:40)
  using 1 GPU(s)
  using 10 OpenMP thread(s) per MPI task
package kokkos
# 3d Lennard-Jones melt

variable	x index 1
variable	y index 1
variable	z index 1
variable        t index 1000

variable	xx equal 20*$x
variable	xx equal 20*1
variable	yy equal 20*$y
variable	yy equal 20*1
variable	zz equal 20*$z
variable	zz equal 20*1

units		lj
atom_style	atomic/kk

lattice		fcc 0.8442
Lattice spacing in x,y,z = 1.6796 1.6796 1.6796
region		box block 0 ${xx} 0 ${yy} 0 ${zz}
region		box block 0 20 0 ${yy} 0 ${zz}
region		box block 0 20 0 20 0 ${zz}
region		box block 0 20 0 20 0 20
create_box	1 box
Created orthogonal box = (0 0 0) to (33.5919 33.5919 33.5919)
  2 by 2 by 2 MPI processor grid
create_atoms	1 box
Created 32000 atoms
mass		1 1.0

velocity	all create 1.44 87287 loop geom

pair_style	lj/cut 2.5
pair_coeff	1 1 1.0 1.0 2.5

neighbor	0.3 bin
neigh_modify	delay 0 every 20 check no

fix		1 all nve

thermo          100

run		$t
run		1000
Neighbor list info ...
  1 neighbor list requests
  update every 20 steps, delay 0 steps, check no
  max neighbors/atom: 2000, page size: 100000
  master list distance cutoff = 2.8
  ghost atom cutoff = 2.8
  binsize = 1.4 -> bins = 24 24 24
Memory usage per processor = 4.38855 Mbytes
Step Temp E_pair E_mol TotEng Press 
       0         1.44   -6.7733681            0   -4.6134356   -5.0197073 
     100    0.7574531   -5.7585055            0   -4.6223613   0.20726105 
     200   0.75953175   -5.7618892            0   -4.6226272   0.20910575 
     300   0.74624286    -5.741962            0   -4.6226327   0.32016436 
     400   0.74155675   -5.7343359            0   -4.6220356    0.3777989 
     500   0.73249345   -5.7206946            0   -4.6219887   0.44253023 
     600   0.72087255   -5.7029314            0   -4.6216563   0.55730354 
     700   0.71489947    -5.693532            0   -4.6212164   0.61322381 
     800   0.70876958   -5.6840594            0   -4.6209382   0.66822293 
     900   0.70799521   -5.6828388            0   -4.6208791   0.66961276 
    1000   0.70325874   -5.6750827            0   -4.6202276   0.71125863 
Loop time of 12.808 on 80 procs for 1000 steps with 32000 atoms

Performance: 33728.966 tau/day, 78.076 timesteps/s
86.9% CPU use with 8 MPI tasks x 10 OpenMP threads

MPI task timing breakdown:
Section |  min time  |  avg time  |  max time  |%varavg| %total
---------------------------------------------------------------
Pair    | 0.42494    | 0.44689    | 0.50738    |   3.6 |  3.49
Neigh   | 1.8268     | 1.8477     | 1.8672     |   1.1 | 14.43
Comm    | 6.3182     | 6.4078     | 6.5277     |   2.8 | 50.03
Output  | 0.012116   | 0.012511   | 0.012801   |   0.2 |  0.10
Modify  | 3.3076     | 3.3502     | 3.3715     |   1.0 | 26.16
Other   |            | 0.7429     |            |       |  5.80

Nlocal:    4000 ave 4028 max 3968 min
Histogram: 1 1 1 0 0 2 0 0 0 3
Nghost:    5516.62 ave 5550 max 5488 min
Histogram: 2 1 0 0 1 1 1 0 1 1
Neighs:    0 ave 0 max 0 min
Histogram: 8 0 0 0 0 0 0 0 0 0
FullNghs:  299934 ave 303286 max 295483 min
Histogram: 1 0 2 0 1 0 1 0 0 3

Total # of neighbors = 2399476
Ave neighs/atom = 74.9836
Neighbor list builds = 50
Dangerous builds not checked
Total wall time: 0:00:15
~~~
