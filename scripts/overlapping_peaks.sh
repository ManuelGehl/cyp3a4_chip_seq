# Performs pair-wise peak comparison

# Initialize tsv file structure
echo -e "sequences\tseq1_unique\tseq2_unique\toverlap" >> peak_comparison.tsv

# Extract sequence names
filename1="$1"
filename2="$2"
name1=$(echo "$filename1" | cut -d "_" -f1)
name2=$(echo "$filename2" | cut -d "_" -f1)

# Find number of unique peaks in sequence 1
seq1_unique=$(bedtools intersect -a "$filename1" -b "$filename2" -v | wc -l)

# Find number of unique peaks in sequence 2
seq2_unique=$(bedtools intersect -a "$filename2" -b "$filename1" -v | wc -l)

# Find number of overlaping peaks
overlap=$(bedtools intersect -a "$filename1" -b "$filename2" -u | wc -l)

# Append results to tsv
echo -e "${name1}/${name2}\t${seq1_unique}\t${seq2_unique}\t${overlap}" >> peak_comparison.tsv
