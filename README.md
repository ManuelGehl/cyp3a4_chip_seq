# cyp3a4_chip_seq

## Summary
This report presents the findings from a ChIP-seq analysis, detailing the steps from data processing to the identification of regions impacted by Rifampin. 
The key results and their implications are summarized in this section.

## Introduction
ChIP-seq is a method used to analyze protein-DNA interactions across the genome. 
This study aims to identify binding sites and determine how they are influenced by the treatment with Rifampin.

## Quality control $ trimming
This ChIP-seq analysis involved four different ChIP settings, each targeting either a transcription factor (PXR or p300) or a histone modification (H3K4me1 or H3K27ac). 
The experiments were conducted with and without Rifampin to understand the drug's impact on protein-DNA interactions. The dataset also included one input control.
The following table summarizes the experiments and their descriptions:

| Experiment Number | Description                                         |
|-------------------|-----------------------------------------------------|
| SRR1642051        | ChIP-seq on Human Hepatocytes- Rif_K27ac             |
| SRR1642052        | ChIP-seq on Human Hepatocytes- Rif_K4me1             |
| SRR1642053        | ChIP-seq on Human Hepatocytes- DMSO K27ac            |
| SRR1642054        | ChIP-seq on Human Hepatocytes- DMSO K4me1            |
| SRR1642055        | ChIP-seq on Human Hepatocytes- Hu8080 Input          |
| SRR1642056        | ChIP-seq on Human Hepatocytes- DMSO PXR              |
| SRR1642057        | ChIP-seq on Human Hepatocytes- Rif PXR               |
| SRR1642058        | ChIP-seq on Human Hepatocytes- Rif p300              |
| SRR1642059        | ChIP-seq on Human Hepatocytes- DMSO p300             |

The sequencing data was downloaded from the Sequence Read Archive (SRA) using SRAtoolkit and quality control (QC) was performed with FASTQC. The entire process was organized in a shell script named `download_fastqc_pipe.sh`, which automates the download and QC steps for all samples.
Quality assessment revealed notable differences among the sequencing data. While the samples SRR1642051 up to SRR1642055 showed overall good quality, the samples ranging from SRR1642056 to SRR1642059 exhibited several quality issues. These issues included high levels of sequence duplications, adapter contaminations, pronounced GC content shifts, and problems with the sequencing tiles. The samples ranging from SRR1642051 to SRR1642054 also showed slight GC content shifts and occasional tile issues, but these were not as pronounced as in the latter group.

To address these problems, Cutadapt was used to remove adapter sequences from all samples. Following this trimming, a second round of FASTQC analysis was performed to reassess the data quality. This process was organized using a script called `trimming_pipe.sh`. The trimming substantially improved the quality of the problematic samples, especially in terms of reducing adapter contamination and mitigating GC content shifts. However, a slight GC shift was still observed in the trimmed samples, indicating that some underlying issues persisted.

## Read Mapping and quantification

After quality control and trimming, the cleaned reads were mapped against the GrCh38 reference genome using Bowtie1, as the reads had a length of 36 bases. This mapping process was automated using a script named `mapping_pipe.sh`. The experiments from SRR1642051 to SRR1642055 achieved high mapping rates, with over 98% of reads aligning to the reference genome. However, the mapping rates for the experiments with SRR numbers ending in 56 to 59 were significantly lower, ranging from 64% to 77%. Notably, allowing up to 2 mismatches during alignment did not improve the mapping rate.

Following alignment, the resulting SAM files were converted to BAM files, which are a more efficient and compressed binary format. These BAM files were then sorted and indexed using samtools, as outlined in the script `sam_sorting_pipe.sh`.

To visualize the read coverage across the genome, BigWig files were created using deeptools. This process involved extending the read lengths to 200 bp and binning the genome into 30-base-pair windows. The read counts in each bin were then normalized using the RPKM method to account for differences in sequencing depth and fragment length. This conversion process was managed by a script called `bam2bigwig.sh`.


## Peak Calling and Filtering
Peak calling was performed to identify regions of significant protein-DNA interaction. Tools like MACS2 were used, and peaks were filtered to remove false positives or low-confidence calls.

## Genomic Arithmetic
Genomic arithmetic involved operations such as intersecting peaks with gene annotations or other genomic features. Tools like BEDTools were employed for these tasks.

## Annotation and GO-Term Enrichment
The identified peaks were annotated with respect to known genomic features. Gene ontology (GO) term enrichment analysis was conducted to understand the functional significance of these regions.

## Identification of Rifampin-Induced Regions
Comparative analysis was performed to identify regions uniquely associated with Rifampin treatment. Differential peak calling and statistical analysis were used to determine significant changes.
