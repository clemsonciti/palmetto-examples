ScaLAPACK example file `example1.f` shows how to solve system
of linear equations Ax=b using `PDGESV` subroutine. Example is 
taken from [www.netlib.org](http://www.netlib.org/scalapack/examples/example1.f)

1. We will use the ScaLAPACK library from Intel's MKL suite. 
   Load MPI and Intel modules 

        module load intel/15.0
        module load openmpi/1.8.4

   and compile the example program

        mpif77 example1.f -L/software/intel/composer_xe_2015/mkl/lib/intel64 \
          -lmkl_intel_lp64 -lmkl_cdft_core -lmkl_scalapack_lp64 \
          -lmkl_blacs_openmpi_lp64 -lmkl_sequential -lmkl_core -o example.x

2. Examine the script `scalapack.pbs` and adjust numbers of 
   nodes and processors per node. Remember about ScaLAPACK assumptions about 
   the processor's grid. 

3. Submit the job

        qsub scalapack.pbs

4. Examine the result file `output.txt`, it should look like this 

        ScaLAPACK Example Program #1 -- May 1, 1997

        Solving Ax=b where A is a   9 by   9 matrix with a block size of   2
        Running on   6 processes, where the process grid is   2 by   3

        INFO code returned by PDGESV =   0

        According to the normalized residual the solution is correct.

        ||A*x - b|| / ( ||x||*||A||*eps*N ) =   0.00000000E+00
