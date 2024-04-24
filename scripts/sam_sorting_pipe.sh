#!/bin/bash

# Converts sam files into bam files, sorts them and indexes them
for acc in "$@"
do
	echo ""; echo "Processing : "$acc""; echo ""

	samtools view ../results/mapped/"$acc".sam --bam --threads 4 | \
 	samtools sort -@ 4 - -T "$acc" -o ../results/mapped/"$acc"_sorted.bam
	
	samtools index ../results/mapped/"$acc"_sorted.bam
done
