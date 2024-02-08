#!/usr/bin/env bash

source ~/.bashrc.conda #needed to make "conda" command to work
conda activate qiime2-2023.2

set -xeuo pipefail

if [[ -f config.yaml ]]; then
    echo "Must have a config.yaml to be able to run"
    exit 1
fi

snakemake --profile ./ --dryrun
