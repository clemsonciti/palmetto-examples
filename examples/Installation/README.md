## Installing software on Palmetto

In this example,
we show how to install a simple program
(the [GNU Hello](https://www.gnu.org/software/hello/) program).

1. Request an interactive job
(all compilation should be done on a compute node)

        qsub -I -l select=1:ncpus=1,walltime=2:00:00

2. Download the source code for the Hello program:

        wget http://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz

3. Unpack the downloaded file

        tar zxvf hello-2.10.tar.gz

4. Load the modules needed for compilation

        module load gcc/4.8.1

5. Compile and install the program

        cd hello-2.10
        ./configure --prefix=$HOME/software/hello
        make
        make install

6. Modify the shell environment, and test the program

        export PATH=$HOME/software/hello/bin:$PATH
        hello

