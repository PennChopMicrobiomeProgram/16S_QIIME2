FROM quay.io/qiime2/amplicon:2025.10

# Create a working directory
WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git

# Install snakemake
RUN conda install -c bioconda -c conda-forge snakemake

# Install dnabc
RUN git clone https://github.com/PennChopMicrobiomeProgram/dnabc.git
RUN cd dnabc && pip install .

# Install unassigner
RUN git clone https://github.com/PennChopMicrobiomeProgram/unassigner.git
RUN cd unassigner && pip install .

# Copy rules, scripts, and environment file to the container
COPY rules/ ./rules/
COPY scripts/ ./scripts/
COPY Snakefile .

CMD ["snakemake"]