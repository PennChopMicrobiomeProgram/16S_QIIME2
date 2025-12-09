# 16S_QIIME2
This is a Snakemake based 16S QIIME2 pipeline.

## Installation
To install, we assume you already have installed `Miniconda3 (4.7.10+)` (https://docs.conda.io/en/latest/miniconda.html)
- Clone this repository:
```bash
git clone https://github.com/PennChopMicrobiomeProgram/16S_QIIME2.git
```

### 2025 10 process
See the updated qiime docs here: https://library.qiime2.org/quickstart/amplicon

### 2023 02 process
- Create a conda environment:
```bash
cd 16S_QIIME2
conda create --name qiime2-2023.2 --file environment.yml
```
If this doesn't work or you're not on a linux platform, you can manually install following these instructions: (https://docs.qiime2.org/2023.9/install/native/)

To run the pipeline, activate the envrionment (currently based on **QIIME2 2023.2**) by entering
`conda activate qiime2-2023.2`

- The following software also need to be installed within the environment you created:
  - `dnabc` (https://github.com/PennChopMicrobiomeProgram/dnabc)

## Required input files for the pipeline
To run the pipeline, we need
- Multiplexed R1/R2 read pairs (Undetermined_S0_L001_R1_001.fastq.gz, Undetermined_S0_L001_R2_001.fastq.gz), and
- QIIME2 compatible mapping file
  - Tab delimited
  - The first two columns should be `SampleID` (or `#SampleID`) and `BarcodeSequence`

## Databases required
`Qiime2 classifier` (https://docs.qiime2.org/2023.2/data-resources/)
`dada2 training set` (https://benjjneb.github.io/dada2/training.html)

## How to run
- Create a project directory, e.g. `~/16S_QIIME2/test` and put the mapping file, e.g. `test_mapping_file.tsv` in the project directory. If you are running this on the cluster, the data would be staged in a scratch drive e.g. `/scr1/username`
- Edit `qiime2_config.yml` so that it suits your project. In particular,
  - **all: project**: path to the project directory, e.g. `~/16S_QIIME2/test`
  - **all: mux_dir**: the direcotry containing multiplexed R1/R2 read pairs, e.g. `~/16S_QIIME2/test/multiplexed_fastq` 
  - **all: mapping**: the name of mapping file, e.g. `test_mapping_file.tsv`
- Edit `config.yaml` for platform specific settings (currently formatted for SLURM on republica)
- (Optional) Edit `rules\targets\targets.rules` to comment out steps you don't need (e.g. `#TARGET_PICRUST2`)
- To run the pipeline, activate the envrionment by entering `conda activate qiime2-2023.2`, `cd` into `16S_QIIME2` and execute `snakemake --profile ./`
  - If using `sbatch` you can just execute the script `./run_snakemake.bash`
  - You can also do a dryrun: `./dryrun_snakemake.bash`
  
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

### dada2_species
#### Input
- Representative sequences (fasta)
#### Output
- Dada2 species assignments (tsv)
- Dada2 Raw data for loading in R (RData format)

### vsearch
#### Input
- Representative sequences (fasta)
#### Output
- Vsearch report (tsv) customized to be like BLAST results (see config.yml)
- Vsearch list of representative sequences that aligned (fasta)

NB: Currently picrust2-2021.11_0 does not work with qiime2 2023.2 but these would be the outputs if it did:
### picrust2

#### Input
- Feature table (QIIME2 artifact, tsv)
- Representative sequences (QIIME2 artifact, fasta)

#### Output
- KEGG orthologs counts (tsv)
- Enzyme classification counts (QIIME2 artifact)
- KEGG pathway counts (QIIME2 artifact)

## Updating qiime2

1. Manually install a new version of qiime2 using conda (https://docs.qiime2.org/2023.9/install/native/)
2. Update the `environment.yml` using:
3. `conda activate myenv`
4. `conda env export > environment.yml`
5. git commit / push your changes (to your own fork) and create a pull request for PennCHOPMicrobiomeProgram/16S_QIIME2

## Docker

### Building and running the image with Docker

You can do this replacing `ctbushman` with your own DockerHub repo name so that you can actually push to DockerHub and use the image elsewhere easily.

```
cd 16S_QIIME2/
docker build -t ctbushman/16s_qiime2:latest -f Dockerfile .
docker run --rm -it ctbushman/16s_qiime2:latest snakemake -h
docker push ctbushman/16s_qiime2:latest
```

### Building and running the image with Singularity

This step you do once the image is on DockerHub and you want to use it on the HPC. The tmp and cache dirs we set here will help avoid errors you'll run into trying to build big images because the /tmp/ dir on the login nodes will fill up.

```
mkdir /scr1/users/bushmanc1/tmp
mkdir /scr1/users/bushmanc1/cache
export SINGULARITY_TMPDIR=/scr1/users/bushmanc1/tmp
export SINGULARITY_CACHEDIR=/scr1/users/bushmanc1/cache

singularity build /mnt/isilon/microbiome/analysis/software/16s_qiime2_2025.10.sif docker://ctbushman/16s_qiime2:latest
singularity exec --bind /mnt/isilon/microbiome:/mnt/isilon/microbiome /mnt/isilon/microbiome/analysis/software/16s_qiime2_2025.10.sif snakemake --snakefile /app/Snakefile --profile /path/to/project -n
```