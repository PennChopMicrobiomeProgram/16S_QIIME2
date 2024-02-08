#!/usr/bin/env bash

#SBATCH --mem=2G
#SBATCH -n 1
#SBATCH --export=ALL
#SBATCH --mail-user=userid@email
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --no-requeue
#SBATCH -t 72:00:00
#SBATCH --output=slurm_%x_%j.out

if [[ ! -f ./config.yaml ]]; then
    echo "Must have a config.yaml to be able to run"
    exit 1
fi

source ~/.bashrc.conda #needed to make "conda" command to work
conda activate qiime2-2023.2

set -xeuo pipefail

snakemake --profile ./
