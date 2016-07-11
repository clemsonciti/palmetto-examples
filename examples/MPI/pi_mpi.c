// Simple MPI-enabled C code that integrates
// f(x) = 4 / (1 + x*x) from 0:1 to estimate pi

#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
double totarea;  /* total area under the curve */
double ysum;     /* sum of rectangle heights */
double x;        /* midpoint of the interval */
int i, n;        /* iteration number & number of intervals */
double myarea;   /* local area under the curve */
int id, nproc;   /* process rank & number of processes */

MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &id);
MPI_Comm_size(MPI_COMM_WORLD, &nproc);

n = 1000;

MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
ysum = 0.0;
for (i=id; i<=n; i+=nproc) {
x = (1.0/n)*(i-0.5);  //calculate area at interval midpoint
ysum += 4.0/(1.0+x*x);
sleep(1);  //sleep to "simulate" long computation, units are seconds
}

myarea = ysum*(1.0/n);
printf("process %d: myarea %20.18f\n", id, myarea);

MPI_Reduce(&myarea, &totarea, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

if (id == 0) {
    printf("Total area (estimate of pi) is %20.18f\n", totarea);
}

MPI_Finalize();
return 0;
}

