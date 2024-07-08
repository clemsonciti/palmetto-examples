## Nextflow

Nextflow is a workflow management tool commonly used for biological pipelines. 

To see what version of nextflow is available run
~~~
$ module avail nextflow

nextflow/23.10.0
~~~
To run nextflow load both nextflow and openjdk
~~~
$ module load nextflow
$ module load openjdk/17.0.8.1_1
~~~

As an example you can run 1_helloworld.nf which prints hello world to the screen.
~~~
$ nextflow run 1_helloworld.nf
~~~

For a more thorough documentation and explanation of nextflow see our workshop in TBA.
