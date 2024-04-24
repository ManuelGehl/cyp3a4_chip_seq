# Define input ID
input="SRR1642055_sorted.bam"

# Define array with narrow peak experiments
narrow_accessions=("SRR1642056" "SRR1642057" "SRR1642058" "SRR1642059")

# Loop trough accession numbers
for acc in "${@}"
do
	# Check if current accession belongs to narrow peak experiment
	if [[ " ${narrow_accessions[@]} " =~ " ${acc} " ]]; then
		# Perform peak calling
		echo ""; echo "Processing: ${acc}"; echo ""
		macs3 callpeak --treatment ../results/mapped/${acc}_sorted.bam --control ../results/mapped/${input} \
		--name ${acc} --outdir ../results/peaks --gsize hs -p 1e-5 --cutoff-analysis
	else
		# Use FDR cutoff of 1e-4 for broad peak experiments
                echo ""; echo "Processing: ${acc}"; echo ""
                macs3 callpeak --treatment ../results/mapped/${acc}_sorted.bam --control ../results/mapped/${input} \
                --name ${acc} --outdir ../results/peaks --gsize hs -p 1e-5 --cutoff-analysis
	fi
done

# Loop trough accession numbers and filter out blacklisted peaks
for acc in "$@"
do
	bedtools intersect -a ../results/peaks/"$acc"_peaks.narrowPeak -b ../data/ENCFF356LFX.bed -v > ../results/peaks/"$acc"_filtered.bed
done
