#!/bin/bash

FIRST=$(qsub first_job.pbs)
echo $FIRST

SECOND=$(qsub -W depend=afterany:$FIRST second_job.pbs)
echo $SECOND

THIRD=$(qsub -W depend=afterany:$SECOND third_job.pbs)
echo $THIRD
