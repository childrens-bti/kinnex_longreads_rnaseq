# Kinnex Long-Read Sequencing Pipeline

This repository contains a comprehensive CWL-based workflow for processing Kinnex/MAS-Iso-Seq long-read sequencing data. The pipeline implements the complete PacBio Iso-Seq workflow from HiFi reads to final isoform characterization using open-source tools.

## 🔬 Pipeline Overview

The Kinnex/MAS-Iso-Seq pipeline processes long-read sequencing data through several key steps to identify and quantify transcript isoforms. Most tools are available through PacBio's bioconda channel: [pbbioconda](https://github.com/PacificBiosciences/pbbioconda).

### 📊 Workflow Steps

#### 1. **HiFi Reads Input**
Starting point: High-fidelity consensus reads in BAM format

<details>
<summary>📋 HiFi BAM Generation Process</summary>

The HiFi BAM file (e.g., `m84081_250911_195056_s1.hifi_reads.bcM0001.bam`) is generated through:

1. **Subreads Collection**: Raw instrument output from Revio sequencer (`subreads.bam`)
2. **CCS (Circular Consensus Sequencing)**: Builds HiFi consensus reads (Q20-30) from ZMW subreads
3. **Adapter Trimming** (`pbtrim`): Removes library prep adapters and low-quality regions
4. **Base Modification Calling** (`jasmine`): Annotates kinetic features (6mA, 5mC) if enabled
5. **Demultiplexing** (`lima`): Assigns reads to samples using barcode sequences

**Output**: `*.hifi_reads.bcM0001.bam` (barcode 1) and `*.unassigned.bam`
</details>

#### 2. **Segmentation** 
**Tool**: `skera split`  
**Alternative**: Longbow (Broad Institute)

Segments MAS-Seq/Kinnex concatenated reads into individual cDNAs by:
- Removing 5'/3' adapters and primers
- Trimming poly(A/T) tails
- Removing linkers/barcodes/UMIs
- Splitting concatenated inserts into individual segments

**Key Outputs**:
- `segmented.bam` - Successfully segmented reads
- `segmented.non_passing.bam` - Failed segmentation
- `read_segmentation.report.json` - Segmentation statistics

#### 3. **Primer Detection & Full-Length Classification**
**Tools**: `lima` + `isoseq refine`

**Step 3a: Primer Detection**
```bash
lima --isoseq --peek-guess segmented.bam primers.fasta fl_transcripts.bam
```
- Detects Iso-Seq primers in segmented reads
- Demultiplexes by sample (creates files for each barcode)
- Auto-detects primer orientation

**Step 3b: Refinement**
```bash
isoseq refine --require-polya fl_transcripts.IsoSeqX_bc01_5p--IsoSeqX_3p.bam primers.fasta flnc-1.bam
```
- Removes remaining primer sequences
- Identifies full-length reads (both 5' and 3' primers present)
- Filters for poly-A tails
- Removes concatemers

**Key Outputs**:
- `flnc-*.bam` - Full-Length Non-Concatemer reads per sample
- `flnc.report-*.csv` - Per-sample quality metrics
- `isoseq_primers.report.json` - Primer detection summary

#### 4. **Clustering & Consensus Building**
**Tool**: `isoseq cluster2`

```bash
isoseq cluster2 flnc-1.bam transcripts-1.fasta --verbose
```

Clusters FLNC reads by sequence similarity and generates consensus transcripts for each cluster.

**Key Outputs**:
- `transcripts-*.fasta` - Consensus transcript sequences per sample
- `sample*.transcripts.cluster_report.csv` - Clustering statistics
- `sample*.transcripts.fl_counts.csv` - Read counts per transcript
- `isoseq_saturation-*.txt` - Saturation curves

#### 5. **Genome Mapping**
**Tool**: `pbmm2` (wrapper for minimap2)  
**Alternatives**: minimap2, uLTRA

```bash
pbmm2 align reference.fasta transcripts-1.fasta mapped-1.bam --preset ISOSEQ --sort
```

Maps consensus transcripts to reference genome to determine genomic coordinates and splice junctions.

**Key Outputs**:
- `mapped-*.bam` - Genomic alignments per sample
- `mapped.bam-*.bai` - BAM index files
- `isoseq_mapping.report.json` - Mapping statistics

#### 6. **Isoform Collapsing**
**Tool**: `isoseq collapse`  
**Alternatives**: TAMA, FLAIR, StringTie2, TALON

```bash
isoseq collapse mapped-1.bam collapse_isoforms-1.gff
```

Merges redundant transcripts sharing identical exon-intron structures to create a non-redundant isoform set.

**Key Outputs**:
- `collapse_isoforms-*.fasta` - Final collapsed isoform sequences
- `collapse_isoforms-*.gff` - Isoform models with genomic coordinates
- `collapse_isoforms.flnc_count-*.txt` - Read support per isoform
- `collapse_isoforms.group-*.txt` - Read-to-isoform assignments
- `isoseq.report.json` - Overall pipeline summary

#### 7. **Structural Classification & Quality Filtering**
**Tool**: `pigeon`  
**Alternatives**: SQANTI3, TALON, bambu

**Step 7a: Classification**
```bash
pigeon classify collapse_isoforms-1.gff reference.fasta annotation.gtf --fl flnc_count-1.txt
```

**Step 7b: Quality Filtering**
```bash
pigeon filter pigeon.sorted-1.gff --isoforms collapse_isoforms-1.fasta
```

Classifies transcript isoforms and applies quality filters based on structural completeness and support.

**Key Outputs**:
- `pigeon.sorted-*.gff` - All classified isoforms
- `pigeon.classification-*.txt` - Structural classifications
- `pigeon_filtered.sorted-*.gff` - **Quality-filtered isoforms (recommended)**
- `pigeon_filtered_report-*.json` - Filtering statistics

## 📁 Repository Structure

```
kinnex_longreads/
├── tools/                   # CWL CommandLineTool definitions
├── scripts/                 # Analysis scripts   
├── workflows/               # CWL workflows and subworkflows
├── data/                    # Input data
├── manifests/               # Manifest files 
├── params/                  # Workflow parameter files
├── outputs/                 # Pipeline outputs
├── envs/                    # Conda environments
├── main_workflow.cwl        # Main workflow
├── README.md
└── LICENSE
```

## 🎯 Main Pipeline Outputs

### Primary Files for Downstream Analysis
- **Transcript Models**: `pigeon_filtered.sorted-*.gff` + `collapse_isoforms-*.fasta`
- **Quantification**: `collapse_isoforms.flnc_count-*.txt` or `sample*.transcripts.fl_counts.csv`
- **Quality Metrics**: `pigeon_filtered_report-*.json`

## 🚀 Usage

### Prerequisites

- AWS CLI with SSO configuration ([setup guide](https://childrens-bti.github.io/bti-bfx-docs/aws/))
- Docker (for containerized execution)
- Required tools for local EC2 execution: `curl`, `cwltool`, `mount-s3`
- Access to relevant S3 buckets

#### FUSE Configuration for S3 Mounts

Enable the `allow_other` option for FUSE to allow Docker access to S3 mounts.  
**Edit `/etc/fuse.conf` and ensure this line is uncommented:**

```bash
sudo vim /etc/fuse.conf
```

Uncomment or add:
```
user_allow_other
```

This enables `mount-s3 --allow-other ...` functionality and allows Docker containers to access mounted S3 buckets.

### � Data Access from S3

Use the provided script to mount S3 buckets and access your input data:

```bash
# Mount S3 bucket to access input data
bash mount_s3.sh [your-bucket-name] data/
```

### �🐳 Docker Container Setup

The pipeline requires a Docker container with all bioinformatics tools pre-installed. Build the container:

```bash
# Build the Docker image
docker buildx build --platform linux/amd64 -t kinnex_longreads .
```

### 🛠️ Local Environment Setup

The workflow execution also requires a local conda environment for CWL and orchestration tools:

```bash
# Create and activate the conda environment
conda env create -f envs/cwl_env.yml
conda activate cwl_env
```

#### Run the Pipeline

Execute the main workflow using CWL with Docker integration:

```bash
# Run the complete Kinnex pipeline with Docker
cwltool --outdir outputs/ main_workflow.cwl params/kinnex_params.yml

# Run with custom Docker image
cwltool --outdir outputs/ --default-container kinnex_longreads main_workflow.cwl params/kinnex_params.yml
```

### 📋 Input Requirements

- **HiFi BAM files**: High-fidelity consensus reads (`.bam` format)
- **Reference genome**: FASTA format with associated index
- **Annotation file**: GTF/GFF format for gene annotations
- **Primer sequences**: FASTA file containing Iso-Seq primer sequences

### 📤 Output Files

The pipeline generates several key output categories:

#### Final Results
- **`pigeon_filtered.sorted-*.gff`**: Quality-filtered transcript isoforms (recommended for analysis)
- **`collapse_isoforms-*.fasta`**: Final isoform sequences
- **`collapse_isoforms.flnc_count-*.txt`**: Quantification data (read support per isoform)

#### Quality Control
- **`pigeon_filtered_report-*.json`**: Comprehensive filtering and quality statistics
- **`isoseq.report.json`**: Overall pipeline performance metrics
- **`read_segmentation.report.json`**: Segmentation success rates

#### Intermediate Files
- **`flnc-*.bam`**: Full-length non-concatemer reads
- **`transcripts-*.fasta`**: Consensus sequences from clustering
- **`mapped-*.bam`**: Genome-aligned transcripts

## 🔧 Troubleshooting

### Common Issues

**Memory Requirements**: Large datasets may require substantial memory. Monitor resource usage and adjust accordingly.

**Reference Files**: Ensure reference genome and annotation files are properly formatted and indexed.

**Primer Sequences**: Verify primer sequences match your library preparation protocol.

## 📚 Additional Resources

- [PacBio Iso-Seq Documentation](https://isoseq.how/)
- [PacBio Bioconda Channel](https://github.com/PacificBiosciences/pbbioconda)
- [CWL User Guide](https://www.commonwl.org/user_guide/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## 👥 Maintainers

- Primary Contact: Chao Di [cdi1@childrensnational.org]