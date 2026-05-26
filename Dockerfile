# syntax=docker/dockerfile:1.7
# Kinnex/MAS-Iso-Seq Pipeline Docker Image (Miniconda, optimized)
FROM continuumio/miniconda3:24.7.1-0

LABEL maintainer="Chao Di, cdi@childrensnational.org" \
      description="Kinnex/MAS-Iso-Seq long-read pipeline toolset" \
      version="1.0"

ENV DEBIAN_FRONTEND=noninteractive \
    CONDA_AUTO_UPDATE_CONDA=false \
    PATH="/opt/conda/bin:${PATH}"

# Install OS packages
RUN set -eux; \
    apt-get update -y && apt-get install -y --no-install-recommends \
        ca-certificates wget curl git unzip bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Use Mamba inside your Miniconda to speed up solves
RUN conda install -y -n base -c conda-forge mamba \
    && conda clean -a -y

# Channel config once; strict priority to avoid cross-pinning issues
RUN conda config --system --add channels conda-forge \
    && conda config --system --add channels bioconda \
    && conda config --system --set channel_priority strict


# Install stacks with mamba (single transaction) and clean caches
RUN mamba install -y \
        python=3.12 \
        pbmm2 lima isoseq pbccs pbjasmine pbpigeon \
        pbskera samtools bcftools htslib \
        sambamba \
        pandas numpy scipy \
        r-base \
        pandoc \
        gzip \
    && conda clean -a -y

# Install minimal R packages using Rscript
RUN Rscript -e "install.packages(c('tidyverse', 'ggplot2'), repos='https://cloud.r-project.org/')"

COPY scripts/ /scripts/
RUN chmod -R +r /scripts/ && chown -R 1000:1000 /scripts/

## Scripts step removed: scripts/ directory not present
WORKDIR /data
