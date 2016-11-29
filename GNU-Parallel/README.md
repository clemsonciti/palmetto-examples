## Using GNU Parallel to run multiple tasks simultaneously

The GNU Parallel utility is extremely useful for running several
independent tasks simultaneously, e.g., for processing several files
in parallel, or running batches of simulations.

In this example, we demonstrate how GNU parallel can be used to
operate on several input files (in the `inputs` directory).  Each
of these input files contains a small, 3-by-3 matrix.  We have a
program `transpose.py` which produces the transpose of the matrix,
and saves it to the `outputs` directory.  For example, the command:

    python transpose.py inputs/001.txt

will produce `outputs/001.out`, containing the transpose of the
matrix in `inputs/001.txt`.  The transpose takes approximately 5
seconds to perform, and in the file `job.sh`, we demonstrate how
to use the GNU Parallel utility to transpose 4 files at a time.

The following page has several more examples of GNU Parallel for
different tasks, including distributing tasks among multiple machines:

https://www.gnu.org/software/parallel/man.html

Based on the above examples, a simple example of distributing tasks
among multiple nodes using GNU Parallel is also provided in
`multi-node-job.sh`.
