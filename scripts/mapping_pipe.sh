#! /bin/bash

# Accepts list of run numbers SRR...

# Define path to index
REF="../data/GRCh38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set"

# Loop over fastq files and map reads to reference genome
for acc in "$@"
do
	echo ""; echo "Processing : "$acc""; echo ""

	bowtie -x "$REF" -q ../data/processed/"$acc"_trimmed.fastq --sam ../results/mapped/"$acc".sam \
	--threads 14 --best  --chunkmbs 320 --time
done
