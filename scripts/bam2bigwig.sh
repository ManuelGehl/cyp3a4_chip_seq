#!/bin/bash

# Converts bam files to bigwig files

for acc in "$@"
do
	echo ""; echo "Processing : "$acc""; echo ""

	bamCoverage --bam ../results/mapped/"$acc"_sorted.bam --outFileName ../results/bigwigs/"$acc".bw \
	--binSize 30 --numberOfProcessors 14 --normalizeUsing RPKM --smoothLength 300 --extendReads 200
done
