# 16S_QIIME2
This is a Snakemake based 16S QIIME2 pipeline.

## Software requirement
We assume that the following software are installed:
- `QIIME2 version 2019.4` (https://docs.qiime2.org/2019.4)
- `dnabc` (https://github.com/PennChopMicrobiomeProgram/dnabc)
- `unassigner` (https://github.com/kylebittinger/unassigner)

To run the pipeline, activate the QIIME2 version 2019.4 envrionment by entering e.g.,
`source activate qiime2-2019.4`
(Make sure to install `dnabc` and `unassigner` in the QIIME2 version 2019.4 envrionment)

## Input
To run the pipeline, we need
- Multiplexed R1/R2 read pairs (Undetermined_S0_L001_R1_001.fastq.gz, Undetermined_S0_L001_R2_001.fastq.gz), and
- QIIME2 compatible mapping file
  - Tab delimited
  - The first two columns should be `SampleID` (or `#SampleID`) and `BarcodeSequence`

## Intermediate steps and corresponding input/output

### Demultiplexing
#### Input
- Multiplexed R1/R2 read pairs
- QIIME2 compatible mapping file
#### Output
- Demultiplexed fastq(.gz) files
- Total read count summary (tsv)
- QIIME2 compatible manifest file (csv)

### QIIME2 import
#### Input
- QIIME2 compatible manifest file
- Demultiplexed fastq files
#### Output
- QIIME2 PairedEndSequencesWithQuality artifact and corresponding visualization
- QIIME2-generated demultiplexing stats

### DADA2 denoise
#### Input
- QIIME2 PairedEndSequencesWithQuality artifact
#### Output
- Feature table (QIIME2 artifact, tsv)
- Representative sequences (QIIME2 artifact, fasta)

### Taxonomy classification
#### Input
- Representative sequences 
#### Output
- Taxonomy classification table (QIIME2 artifact, tsv) 

### Tree building
#### Input
- Representative sequences 
#### Output
- Aligned sequence
- Masked (aligned) sequence
- Unrooted tree
- Rooted tree

### Diversity calculation
#### Input
- Rooted tree
#### Output
- Various QIIME2 diversity metric artifacts
- Faith phylogenetic diversity vector (tsv)
- Weighted/unweighted UniFrac distance matrices (tsv)

### Unassigner
#### Input
- Representative sequences (fasta)
#### Output
- Unassigner output (tsv) for species level classification of representative sequences

### Basic Bioinformatics Report
#### Input
- QIIME2 compatible mapping file and output from diversity calculation 
#### Output
- Basic Bioinformatics Report containging heatmap, relative proportion bar graph, alpha diversity plots, beta diversity plots, and per sample read counts in HTML format.
