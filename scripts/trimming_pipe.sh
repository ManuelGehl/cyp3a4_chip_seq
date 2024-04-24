#!/bin/bash

# Accepts list of run numbers SRR...
# Loop over fastq files and remove Illumina adapter GATCGGAAGAGCTCGTATGCCGTCTTCTGCTTGAAA
for acc in "$@"
do
	echo ""; echo "Processing : "$acc""; echo ""

	cutadapt ../data/raw_data/"$acc".fastq --output ../data/processed/"$acc"_trimmed.fastq \
	--cores 0 -g ^GATCGGAAGAGCTCGTATGCCGTCTTCTGCTTGAAA --discard-trimmed

	# Run FASTQC
	fastqc ../data/processed/"$acc"_trimmed.fastq --outdir ../results/fastqc --threads 10 

done
