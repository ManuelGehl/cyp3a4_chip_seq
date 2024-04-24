#!/bin/bash

# Loop over each accession number
for acc in "$@"
do
	echo ""; echo "Processing : "$acc""; echo ""
	prefetch "$acc" --progress --output-directory ../data
	fasterq-dump ../data/"$acc" --outdir ../data --progress --threads 10
	fastqc ../data/"$acc".fastq --outdir ../results/fastqc --threads 10
done
