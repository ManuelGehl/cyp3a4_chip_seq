# cyp3a4_chip_seq

## Summary
This project, based on the ChIP-seq analysis from the paper by Smith et al. (2014) titled "Genome-Wide Discovery of Drug-Dependent Human Liver Regulatory Elements", investigated the effect of rifampin treatment on protein-DNA interactions in human hepatocytes. The study focused on specific transcription factors (PXR, p300) and histone modifications (H3K4me1, H3K27ac) associated with active expression, comparing ChIP-seq data from DMSO- and rifampin-treated samples.

Trimmed reads were mapped to the GrCh38 genome using `Bowtie1`, and unique and overlapping peaks were identified using `BEDtools`, followed by peak calling using `MACS3`. Data were filtered against blacklisted regions to remove genomic artifacts.

Rifampin-induced regions (RIRs) were identified by first filtering for peaks that occurred in similar regions for all 4 antibodies in the DMSO-treated and rifampin-treated samples, respectively, and second by excluding peaks in the rifampin dataset that also occurred under DMSO conditions. Annotation with `ChIPSeeker` indicated that most RIRs were located in distal regions, suggesting an association with enhancers. Enrichment analysis with `clusterProfiler` revealed that genes associated with RIRs are involved in key metabolic pathways, including xenobiotic and steroid metabolism, typical hepatocyte functions, and cytochrome P450 enzyme activity.

## Introduction
Drug efficacy can vary widely between patients due to differences in individual genotypes. Many drugs are metabolized in the liver and intestine by enzymes that contribute significantly to the observed differences in drug response between individuals. Understanding these differences is critical to optimizing drug efficacy and minimizing adverse effects.

An important class of drug-metabolizing enzymes is the cytochrome P450 (CYP450) family, of which CYP3A4 is particularly important. CYP3A4 is responsible for metabolizing approximately 50% of all prescription drugs, yet its expression can vary widely (5-20 fold) among individuals. Despite this variability, only a few SNPs in the CYP3A4 gene have been identified that could potentially explain the differential expression. This suggests that other factors, such as distal regulatory elements such as enhancers, may play an important role in driving this variability.

To investigate these putative regulatory elements, a ChIP-seq analysis was performed using antibodies against the 4 targets PXR, p300, H3K27ac and H3K4me1. The pregnane X receptor PXR is activated by a variety of xenobiotics (e.g. rifampin) and has been shown to stimulate CYP3A4 expression. However, the exact binding site of PXR on DNA remains elusive. In combination with other enhancer markers such as p300, H3K27ac and H3K4me1, which are associated with active chromatin, the analysis could help to identify the underlying mechanism of CYP3A4 expression differences.

## Quality control & trimming
This ChIP-seq analysis involved four different ChIP settings, each targeting either a transcription factor (PXR or p300) or a histone modification (H3K4me1 or H3K27ac). 
The experiments were conducted with and without Rifampin to understand the drug's impact on protein-DNA interactions. The dataset also included one input control (**Tab. 1**).

<br></br>
**Table 1: Overview about the used datasets.**
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

<br></br>

The sequencing data was downloaded from the Sequence Read Archive (SRA) using SRAtoolkit and quality control (QC) was performed with FASTQC. The entire process was organized in a shell script named `download_fastqc_pipe.sh`, which automates the download and QC steps for all samples.
Quality assessment revealed notable differences among the sequencing data. While the samples SRR1642051 up to SRR1642055 showed overall good quality, the samples ranging from SRR1642056 to SRR1642059 exhibited several quality issues. These issues included high levels of sequence duplications, adapter contaminations, pronounced GC content shifts, and problems with the sequencing tiles. The samples ranging from SRR1642051 to SRR1642054 also showed slight GC content shifts and occasional tile issues, but these were not as pronounced as in the latter group.

To address these problems, Cutadapt was used to remove adapter sequences from all samples. Following this trimming, a second round of FASTQC analysis was performed to reassess the data quality. This process was organized using a script called `trimming_pipe.sh`. The trimming substantially improved the quality of the problematic samples, especially in terms of reducing adapter contamination and mitigating GC content shifts. However, a slight GC shift was still observed in the trimmed samples, indicating that some underlying issues persisted.

## Read Mapping and quantification

After quality control and trimming, the cleaned reads were mapped against the GrCh38 reference genome using Bowtie1, as the reads had a length of 36 bases. This mapping process was automated using a script named `mapping_pipe.sh`. The experiments from SRR1642051 to SRR1642055 achieved high mapping rates, with over 98% of reads aligning to the reference genome. However, the mapping rates for the experiments with SRR numbers ending in 56 to 59 were significantly lower, ranging from 64% to 77%. Notably, allowing up to 2 mismatches during alignment did not improve the mapping rate.

Following alignment, the resulting SAM files were converted to BAM files, which are a more efficient and compressed binary format. These BAM files were then sorted and indexed using samtools, as outlined in the script `sam_sorting_pipe.sh`.

To visualize the read coverage across the genome, BigWig files were created using deeptools. This process involved extending the read lengths to 200 bp and binning the genome into 30-base-pair windows. The read counts in each bin were then normalized using the RPKM method to account for differences in sequencing depth and fragment length. This conversion process was managed by a script called `bam2bigwig.sh`.


## Peak Calling and filtering

Peak calling was performed to identify regions with significant protein-DNA interactions. For this analysis, MACS3 was used, with a p-value cutoff of 1e-5. All samples were analyzed against the input control, SRR1642055, to identify peaks that differed significantly from background noise. After peak calling, the resulting peaks were filtered against blacklisted regions to remove known artifacts or problematic areas in the GrCH38 genome. The blacklisted regions were obtained from the ENCODE project (ENCFF356LFX.bed). The process of peak calling and filtering was organized in a script called `peak_calling_filtering`.

The following table summarizes the number of peaks obtained for each sample after filtering, with the first column indicating the corresponding experiment description:

<br></br>
**Table 2: Number of called peaks for each sample after filtering by p-value < 1e-5 and blacklisted regions.**
| Description                                       | Number of Peaks | Experiment              |
|---------------------------------------------------|-----------------|-------------------------|
| H3K27ac - Rifampin                                | 56,819          | SRR1642051              |
| H3K4me1 - Rifampin                                | 8,093           | SRR1642052              |
| H3K27ac - DMSO                                    | 47,786          | SRR1642053              |
| H3K4me1 - DMSO                                    | 9,111           | SRR1642054              |
| PXR - DMSO                                        | 2,615           | SRR1642056              |
| PXR - Rifampin                                    | 1,547           | SRR1642057              |
| p300 - Rifampin                                   | 2,508           | SRR1642058              |
| p300 - DMSO                                       | 3,402           | SRR1642059              |
| **Total**                                         | **131,881**     | **Total**               |

<br></br>

The total number of resulting peaks across all samples after filtering was 131,881. This peak calling and filtering process provides a set of reliable regions for subsequent analysis, reducing the likelihood of false positives due to genomic artifacts.

## Genomic arithmetic

To assess the unique and intersecting peaks between DMSO- and Rifampin-treated samples, BEDtools was used. A pipeline (`overlapping_peaks.sh`) was created to determine the number of unique and intersecting peaks for each pair of DMSO and Rifampin experiments. The results were outputted as TSV files, and a Jupyter notebook (`venn_diagrams.ipynb`) was used to generate Venn diagrams for visualization.

This analysis revealed that there was no strong recruitment of any transcription factor upon Rifampin treatment (**Fig. 1**). In contrast, the authors of the original study reported a roughly six-fold increase in PXR binding upon Rifampin treatment. However, a significant limitation in the current analysis is the lack of replicates, which affects the reliability of differential binding studies.

<br></br>
<img src=figures/overlap.png width=500>

**Figure 1: Overlap between DMSO and Rifampin-treated samples for each antibody.**
<br></br>

To further understand the impact of Rifampin treatment, all unique peaks from DMSO-treated experiments were combined into `dmso_overlaps.bed`, while all unique peaks from Rifampin-treated experiments were combined into `rif_overlaps.bed`. Using BEDtools, the number of unique peaks in each dataset and their intersection were calculated, aiming to identify peaks that only appear in Rifampin-treated samples but not in DMSO-treated samples. Both DMSO-treated and Rifampin-treated samples show a similar number of intersecting peaks, with each treatment group having approximately 4,700 unique peaks. The overlapping proportion between the two groups is around 2,000 peaks, indicating a significant intersection between the different treatment conditions (**Fig. 2**). The 2708 unique peaks are candidates for regions potentially recruited by Rifampin treatment and were designated as Rifampin-Induced Regions (RIRs) by the authors of the study.

<br></br>
<img src=figures/overlap2.png width=500>

**Figure 2: Overlap between DMSO and Rifampin-treated samples for all antibodies.**
<br></br>

A significant observation from the analysis was the identification of Rifampin-Induced Regions (RIRs) in the genomic vicinity of the open reading frame (ORF) of CYP3A4. CYP3A4 is one of the genes with the highest differential expression upon Rifampin treatment, as previously reported. Two RIRs were identified in this region. The first corresponds to the promoter region of CYP3A4, suggesting a possible mechanism for the gene's increased expression. The second RIR aligns with an enhancer located near the proximal CYP3A7 gene (**Fig. 3**). This finding is consistent with the results reported by the authors of the original study.

<br></br>
<img src=figures/igv_overlap.png width=500>

**Figure 3: Overlap of ChIP-seq peaks in the genomic vicinity of the cyp3a4 locus.** Blue color indicates DMSO-treated samples and red color indicates rifampin-treated samples.
<br></br>

## Annotation and enrichment analysis

The Rifampin-Induced Regions (RIRs) were annotated using ChIPSeeker, with the TxDb.Hsapiens.UCSC.hg38.knownGene database and the org.Hs.eg.db package. This annotation process was conducted using the script `peak_annotation.rmd`. The analysis revealed that most of the identified peaks were located in distal regions rather than promoter regions, which aligns with the findings of the original study (**Fig. 4**). This suggests that the RIRs might be linked to regulatory elements such as enhancers.

<br></br>
<img src=figures/annotation_pie.png width=500>

**Figure 4: Gene structure annotation and distribution of peaks for Rifampin-induced regions.** Only a minority of peaks are located in promoter regions, while most are found in more distal regions. This distribution suggests that the majority of ChIP-seq peaks are associated with distal regulatory elements such as enhancers.
<br></br>

The list of annotated peaks was then used to perform enrichment analyses on Gene Ontology (GO) terms and KEGG pathways. The enrichment analysis was carried out using clusterProfiler, with a p-value cutoff of 0.05 and a q-value cutoff of 0.01. This part of the analysis was scripted in `enrichment_analysis.rmd`. For the GO terms 74 enriched terms were found, while for KEGG only 5 enriched pathways were found. The enrichment analyses yielded results consistent with those from the original study. Most genes associated with the RIRs were linked to xenobiotic and steroid metabolism pathways, as well as typical hepatocyte functions like alcohol metabolism, lipid metabolism, and cholesterol metabolic processes (**Fig. 5 + Fig. 6**). These functions are closely related to the activity of cytochrome P450 enzymes, suggesting a connection between the RIRs and key metabolic pathways in hepatocytes.

<br></br>
<img src=figures/go_enrichment.png width=500>

**Figure 5: GO enrichment analysis.** Displayed are the top 20 Gene Ontology (GO) terms from the Biological Process (BP) category, sorted by the FDR-adjusted p-value.
<br></br>

<br></br>
<img src=figures/kegg_enrichment.png width=500>

**Figure 6: KEGG enrichment analysis.** Displayed are the enriched KEGG pathway terms, sorted by the FDR-adjusted p-value.
<br></br>

## Reference

Smith, R.P. et al. (2014) ‘Genome-Wide Discovery of Drug-Dependent Human Liver Regulatory Elements’, PLoS Genetics, 10(10), p. e1004648. Available at: https://doi.org/10.1371/journal.pgen.1004648.
