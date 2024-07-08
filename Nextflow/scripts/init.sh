#!/bin/bash
module load biocontainers
module load qiime2
mkdir moving_picture_tutorial
cd ./moving_picture_tutorial
wget https://data.qiime2.org/2023.9/tutorials/moving-pictures/sample_metadata.tsv
mkdir emp-single-end-sequences
cd ./emp-single-end-sequences
wget https://data.qiime2.org/2023.9/tutorials/moving-pictures/emp-single-end-sequences/barcodes.fastq.gz
wget https://data.qiime2.org/2023.9/tutorials/moving-pictures/emp-single-end-sequences/sequences.fastq.gz
cd ..
