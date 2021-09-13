This is an example of how to run CP2K.

To run it, create a folder called, say, cp2k_test:
cd
mkdir cp2k_test
cd cp2k_test

You can get a simple dataset (argon.inp) from this repository or you can download it from their website. To download it from the website, do this:
wget https://www.cp2k.org/_media/exercises:2019_uzh_acpc2:argon.zip
unzip exercises\:2019_uzh_acpc2\:argon.zip

To run cp2k on this example, you can use job.sh from this repository. You can modify it if necessary. 
qsub job.sh

NOTE for Skylight users: please use the file job_skylight.sh instead of job.sh. Again, modify it as you see fit (just make sure you keep the "#PBS -q skygpu" line).

The output will be stored in output.txt file.

Enjoy!
