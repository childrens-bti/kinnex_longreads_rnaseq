# Kinnex/MAS-Iso-Seq Pipeline Docker Image
# Base image with conda and bioinformatics tools
FROM continuumio/miniconda3:latest

# Set metadata
LABEL maintainer="Chao Di, cdi@childrensnational.org"
LABEL description="Complete toolset for Kinnex/MAS-Iso-Seq long-read sequencing pipeline"
LABEL version="1.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/conda/bin:$PATH"
ENV CONDA_AUTO_UPDATE_CONDA=false

# Update system packages and install essential tools
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    unzip \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    mercurial \
    subversion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add conda-forge and bioconda channels
RUN conda config --add channels defaults \
    && conda config --add channels bioconda \
    && conda config --add channels conda-forge \
    && conda config --set channel_priority strict

# Install PacBio and bioinformatics tools
RUN conda install -y \
    # Core PacBio tools from pbbioconda
    pbccs \
    pbtrim \
    jasmine \
    lima \
    skera \
    isoseq \
    pbmm2 \
    pigeon-classify \
    pigeon-filter \
    # Alternative/additional tools
    minimap2 \
    samtools \
    bcftools \
    htslib \
    # Utility tools
    curl \
    # Python packages for data processing
    python=3.12 \
    pandas \
    numpy \
    scipy \
    matplotlib \
    seaborn \
    # R and packages for analysis
    r-base=4.4 \
    r-essentials \
    r-tidyverse \
    r-ggplot2 \
    # File processing tools
    gzip \
    && conda clean -all

# Install longbow (alternative segmentation tool)
RUN pip install longbow-pipeline

# Copy custom scripts
COPY scripts/ /usr/local/scripts/
RUN chmod +x /usr/local/scripts/*

# Add scripts to PATH
ENV PATH="/usr/local/scripts:$PATH"

# Create working directory
RUN mkdir -p /data

# Set working directory
WORKDIR /data