# Kinnex Long-Read Sequencing Pipeline

This repository contains a comprehensive CWL-based workflow for processing Kinnex/MAS-Iso-Seq long-read sequencing data. The pipeline implements the complete PacBio Iso-Seq workflow from HiFi reads to final isoform characterization using open-source tools.

## 🔬 Pipeline Overview

The Kinnex/MAS-Iso-Seq pipeline processes long-read sequencing data through several key steps to identify and quantify transcript isoforms. All tools are available through PacBio's bioconda channel: [pbbioconda](https://github.com/PacificBiosciences/pbbioconda).

### 📊 Workflow Steps

#### 1. **HiFi Reads Input(provided by PacBio)**
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
- Removing segmentation adapters
- Splitting concatenated inserts into individual segments

**Key Outputs**:
- `segmented.bam` - Successfully segmented reads
- `segmented.non_passing.bam` - Failed segmentation
- `segmented.summary.csv` - Segmentation statistics

#### 3. **Primer Detection & Full-Length Classification**
**Tools**: `lima` + `isoseq refine`

**Step 3a: Primer Detection**
```bash
lima --isoseq --peek-guess segmented.bam primers.fasta fl.barcode-pair.bam
```
- Example of `barcode-pair`: `IsoSeqX_bc01_5p--IsoSeqX_3p`
- Detects Iso-Seq primers in segmented reads
- Demultiplexes by sample (creates files for each barcode)
- Auto-detects primer orientation

**Step 3b: Refinement**
```bash
isoseq refine --require-polya fl.barcode-pair.bam primers.fasta flnc.barcode-pair.bam
```
- Removes remaining primer sequences
- Identifies full-length reads (both 5' and 3' primers present)
- Filters for poly-A tails
- Removes concatemers

**Key Outputs**:
- `flnc.*.bam` - Full-Length Non-Concatemer reads per sample
- `flnc.*.report.csv` - Per-sample quality metrics
- `isoseq_primers.report.json` - Primer detection summary (pbconda version does not have this output)

#### 4. **Clustering & Consensus Building**
**Tool**: `isoseq cluster2`

```bash
isoseq cluster2 flnc-1.bam transcripts-1.bam
```

Clusters FLNC reads by sequence similarity and generates consensus transcripts for each cluster.

**Key Outputs**:
- `clustered.*.transcripts.bam` - Consensus transcript sequences per sample
- `clustered.*.transcripts.cluster_report.csv` - Clustering statistics
- `sample*.transcripts.fl_counts.csv` - Read counts per transcript (pbconda version does not have this output)
- `isoseq_saturation-*.txt` - Saturation curves (pbconda version does not have this output)

#### 5. **Genome Mapping**
**Tool**: `pbmm2` (wrapper for minimap2)  
**Alternatives**: minimap2, uLTRA

```bash
pbmm2 align reference.fasta transcripts-1.bam mapped-1.bam --preset ISOSEQ --sort
```

Maps consensus transcripts to reference genome to determine genomic coordinates and splice junctions.

**Key Outputs**:
- `mapped-*.bam` - Genomic alignments per sample
- `mapped.bam-*.bai` - BAM index files
- `isoseq_mapping.report.json` - Mapping statistics (pbconda version does not have this output)

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

**Step 7b: Quality Filtering & Reporting**
```bash
pigeon filter pigeon_classification-1.txt --isoforms collapse_isoforms-1.sorted.gff
pigeon report pigeon.filtered_lite_classification-1.txt output.saturation.txt
```

Classifies transcript isoforms and applies quality filters based on structural completeness and support, then generates saturation analysis reports.

**Key Outputs**:
- `*.classification.txt` - Structural classifications per transcript
- `*.junctions.txt` - Junction information and coverage
- `*.filtered_lite_classification.txt` - Quality-filtered classifications
- `*.filtered_lite_junctions.txt` - Filtered junction information  
- `*.filtered_lite_reasons.txt` - Filtering reason codes
- `*.sorted.filtered_lite.gff` - Quality-filtered isoform annotations
- `*.filtered.report.json` - Detailed filtering statistics
- `*.filtered.summary.txt` - Summary filtering metrics
- `*.saturation.txt` - Transcript saturation analysis

## 📁 Repository Structure

```
kinnex_longreads/
├── tools/                   # CWL CommandLineTool definitions
│   ├── isoseq_cluster2.cwl
│   ├── isoseq_collapse.cwl  
│   ├── isoseq_refine.cwl
│   ├── lima_isoseq.cwl
│   ├── list_files_by_pattern.cwl
│   ├── pbmm2_align.cwl
│   ├── pigeon_classify.cwl
│   ├── pigeon_filter.cwl
│   ├── pigeon_prepare.cwl
│   ├── pigeon_report.cwl
│   └── skera_split.cwl
├── workflows/               # CWL workflows and subworkflows  
│   ├── isoseq_cluster2_scatter.cwl
│   ├── isoseq_collapse_scatter.cwl
│   ├── isoseq_refine_scatter.cwl
│   ├── lima_isoseq_run.cwl
│   ├── pbmm2_align_scatter.cwl
│   ├── pigeon_classify_scatter.cwl
│   ├── pigeon_filter_report_scatter.cwl
│   └── skera.cwl
├── scripts/                 # Analysis scripts   
├── data/                    # Input data
├── manifests/               # Manifest files 
├── params/                  # Workflow parameter files
│   ├── *_test.yml          # Test parameter files for each workflow
│   └── kinnex_params.yml   # Main pipeline parameters
├── outputs/                 # Pipeline outputs
│   ├── skera_test/
│   ├── lima_isoseq_test/
│   ├── isoseq_refine_test/
│   ├── isoseq_cluster2_test/
│   ├── pbmm2_align_scatter_test/
│   ├── isoseq_collapse_scatter_test/
│   ├── pigeon_classify_scatter_test/
│   └── pigeon_filter_report_scatter_test/
├── envs/                    # Conda environments
│   └── cwl_env.yml
├── run_data.sh              # Test execution scripts
├── main_workflow.cwl        # Main workflow
├── README.md
└── LICENSE
```

## 🎯 Quick Reference: Key Outputs

After successful workflow completion, find these primary files in `outputs/kinnex_output/`:

| Output Type | Files | Description |
|-------------|-------|-------------|
| **Transcript Models** | `*.sorted.filtered_lite.gff` | Quality-filtered isoform annotations |
| **Sequences** | `collapse_isoforms.*.fasta` | Collapsed isoform sequences |
| **Quantification** | `collapse_isoforms.*.flnc_count.txt` | Read support per isoform |
| **Quality Metrics** | `pigeon.*.filtered.report.json` | Comprehensive filtering statistics |
| **Saturation** | `pigeon.*.saturation.txt` | Transcript discovery completeness |

📋 For detailed outputs from each step, see [Pipeline Outputs](#-pipeline-outputs) section below.

## 🚀 Running the Complete Pipeline

### Prerequisites

#### AWS & EC2 Setup
- AWS CLI with SSO configuration ([setup guide](https://childrens-bti.github.io/bti-bfx-docs/aws/))
- EC2 instance with sufficient resources (see [Resource Requirements](#resource-requirements))
- Docker installed and running
- Access to relevant S3 buckets

#### Required Tools
- `cwltool` - CWL workflow executor
- `docker` - Container runtime
- `mount-s3` - FUSE-based S3 mounting utility
- `curl` - Data transfer utility

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

### Step-by-Step Execution on EC2

#### 1. Environment Setup

```bash
# Clone the repository
git clone https://github.com/childrens-bti/kinnex_longreads.git
cd kinnex_longreads

# Create and activate the conda environment
conda env create -f envs/cwl_env.yml
conda activate cwl_env

# Build the Docker container with all tools
docker buildx build --platform linux/amd64 -t pgc-images.sbgenomics.com/chaodi/kinnex_longreads:v1.0 .
```

#### 2. Data Access from S3

Mount your S3 bucket to access input data:

```bash
# Mount S3 bucket containing HiFi reads
bash mount_s3.sh your-bucket-name data/your-bucket-name

# Verify data is accessible
ls data/your-bucket-name/
```

#### 3. Configure Pipeline Parameters

Edit `params/main_params.yml` with your data paths:

```bash
nano params/main_params.yml
```

**Required inputs to configure:**
```yaml
# Input data
hifi_dir:
  class: Directory
  path: data/your-bucket-name/path/to/hifi_bams/

# Primers for segmentation (Skera)
primers_fa:
  class: File
  path: data/primers/mas8_primers.fasta

# Primers for demultiplexing (Lima) - must have _5p/_3p suffixes
lima_barcodes:
  class: File
  path: data/primers/IsoSeq_v2_primers_12.fasta

# Reference genome
reference_fa:
  class: File
  path: data/reference/GRCh38.primary_assembly.genome.fa

# Gene annotation
annotation_gtf:
  class: File
  path: data/annotation/gencode.v39.primary_assembly.annotation.gtf
```

**Optional parameters to tune:**
```yaml
# Thread settings (0 = auto-detect)
skera_threads: 0
lima_threads: 0
refine_threads: 0
cluster_threads: 0
pbmm2_threads: 0
collapse_threads: 0

# Quality filtering
refine_require_polya: true
filter_min_cov: 3
filter_polya_percent: 0.6
```

#### 4. Run the Complete Pipeline

Execute the main workflow:

```bash
# Run with temp/output directory control
cwltool \
  --leave-tmpdir \
  --tmpdir-prefix ./.cwl-tmp/ \
  --tmp-outdir-prefix ./.cwl-out/ \
  --outdir outputs/kinnex_output \
  main_workflow.cwl \
  params/main_params.yml
```

**Command options explained:**
- `--leave-tmpdir`: Keep temporary files for debugging
- `--tmpdir-prefix ./.cwl-tmp/`: Store temp files locally
- `--tmp-outdir-prefix ./.cwl-out/`: Store intermediate outputs locally
- `--outdir outputs/kinnex_output`: Final output directory

#### 5. Monitor Progress

The pipeline executes 14 major steps sequentially:

| Step | Tool | Description | 0.1% Sample Runtime* |
|------|------|-------------|---------------------|
| 1 | Skera | Segment HiFi reads | ~3 min |
| 2 | Lima | Demultiplex by barcodes | ~12 min |
| 3 | IsoSeq Refine | Trim & filter FLNC reads | ~1 min |
| 4 | IsoSeq Cluster2 | Cluster into transcript models | ~5 min |
| 5 | PBMM2 | Align transcripts to reference | ~8 min |
| 6 | IsoSeq Collapse | Collapse into unique isoforms | <1 min |
| 7 | Pigeon Classify | Classify against annotation | ~5 min |
| 8 | Pigeon Filter & Report | Quality filter & reports | <1 min |

**Total time for 0.1% sample:** ~35 minutes (6 barcodes, ~80k HiFi reads)

*Based on actual run with 0.1% sampled HiFi reads (6 barcodes) on `m6i.4xlarge` EC2 instance (16 vCPUs, 64 GB RAM)  
**Full dataset projection (100% = 1000x data): Roughly 10-30 hours** depending on dataset complexity and clustering efficiency (not all steps scale linearly). Recommend testing with 1% and 10% samples to calibrate runtime estimates for your specific data.

#### 6. Output Collection

**Important:** CWL only copies outputs to the final `--outdir` upon **successful workflow completion**. 

- ✅ **During execution**: Intermediate outputs in `.cwl-out/*/` directories
- ✅ **On success**: All outputs copied to `outputs/kinnex_output/`
- ❌ **On failure**: Only completed steps' outputs may be in final directory

### 📋 Input Data Requirements

- **HiFi BAM files**: High-fidelity consensus reads (`.bam` + `.bam.pbi` index)
- **Primers FASTA** (Skera): Adapter/barcode sequences (e.g., `mas8_primers.fasta`)
- **Barcodes FASTA** (Lima): Primers with `_5p` and `_3p` suffixes (e.g., `IsoSeq_v2_primers_12.fasta`)
- **Reference genome**: Uncompressed or bgzip-compressed FASTA
- **Annotation GTF**: Standard GTF format for gene annotations

### 📤 Pipeline Outputs

All outputs are in `outputs/kinnex_output/` upon successful workflow completion.

#### Step-by-Step Outputs

<details>
<summary><b>Step 1: Skera (Segmentation)</b></summary>

- **`segmented.bam`** + `.pbi`: Successfully segmented reads
- **`segmented.non_passing.bam`** + `.pbi`: Reads failing segmentation
- **`segmented.consensusreadset.xml`**: Dataset XML (optional)
- **`segmented.summary.csv`**: Segmentation statistics
- **`segmented.ligations.csv`**: Ligation events
- **`segmented.read_lengths.csv`**: Read length distributions
- **`segmented.found_adapters.csv.gz`**: Adapter detection details

</details>

<details>
<summary><b>Step 2: Lima (Demultiplexing)</b></summary>

- **`fl.IsoSeqX_bc##_5p--IsoSeqX_3p.bam`** + `.pbi`: Per-barcode demultiplexed BAMs
- **`fl.consensusreadset.xml`**: Lima output dataset XML
- **`fl.lima.counts`**: Read counts per barcode
- **`fl.lima.report`**: Detailed demultiplexing report
- **`fl.lima.summary`**: Summary statistics
- **`lima-isoseq.log`**: Lima execution log

</details>

<details>
<summary><b>Step 3: IsoSeq Refine (FLNC Filtering)</b></summary>

- **`flnc.IsoSeqX_bc##_5p--IsoSeqX_3p.bam`** + `.pbi`: Full-length non-concatemer reads per barcode
- **`flnc.IsoSeqX_bc##_5p--IsoSeqX_3p.filter_summary.json`**: Filtering statistics
- **`flnc.IsoSeqX_bc##_5p--IsoSeqX_3p.report.csv`**: Per-barcode quality metrics

</details>

<details>
<summary><b>Step 4: IsoSeq Cluster2 (Clustering)</b></summary>

- **`clustered.IsoSeqX_bc##_5p--IsoSeqX_3p.transcripts.bam`** + `.pbi`: Consensus transcript sequences per sample
- **`clustered.IsoSeqX_bc##_5p--IsoSeqX_3p.transcripts.cluster_report.csv`**: Clustering statistics
- **`clustered.IsoSeqX_bc##_5p--IsoSeqX_3p.transcripts.singletons.bam`**: Singleton reads (if enabled)

</details>

<details>
<summary><b>Step 5: PBMM2 (Genome Alignment)</b></summary>

- **`mapped.IsoSeqX_bc##_5p--IsoSeqX_3p.bam`**: Genomic alignments per sample (sorted and indexed)
- **`pbmm2_align_*.log`**: Alignment log files

</details>

<details>
<summary><b>Step 6: IsoSeq Collapse (Isoform Collapsing)</b></summary>

- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.gff`**: Collapsed isoform models with genomic coordinates
- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.fasta`**: Isoform sequences
- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.flnc_count.txt`**: Read support per isoform (for quantification)
- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.group.txt`**: Read-to-isoform assignments
- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.read_stat.txt`**: Read statistics

</details>

<details>
<summary><b>Step 7: Pigeon Classify (Structural Classification)</b></summary>

- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p_classification.txt`**: Structural classification per transcript
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p_junctions.txt`**: Junction information and coverage
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.report.json`**: Classification statistics
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.summary.txt`**: Summary metrics
- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.sorted.gff`**: Sorted isoform annotations

</details>

<details>
<summary><b>Step 8: Pigeon Filter & Report (Quality Filtering)</b></summary>

**Recommended outputs for downstream analysis:**

- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered_lite_classification.txt`**: Quality-filtered classifications
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered_lite_junctions.txt`**: Filtered junction information
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered_lite_reasons.txt`**: Filtering reason codes
- **`collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.sorted.filtered_lite.gff`**: Quality-filtered isoform annotations (GFF)
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered.report.json`**: Comprehensive filtering statistics
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered.summary.txt`**: Summary filtering metrics
- **`pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.saturation.txt`**: Transcript discovery saturation analysis

</details>

#### Key Files for Downstream Analysis

🎯 **Primary outputs to use:**

1. **Transcript annotations**: `*.sorted.filtered_lite.gff` (quality-filtered isoforms)
2. **Transcript sequences**: `collapse_isoforms.*.fasta` (collapsed isoform sequences)
3. **Quantification**: `collapse_isoforms.*.flnc_count.txt` (read counts per isoform)
4. **Quality metrics**: `pigeon.*.filtered.report.json` (filtering statistics)
5. **Saturation**: `pigeon.*.saturation.txt` (sequencing depth assessment)

#### Output Organization

```
outputs/kinnex_output/
├── segmented.bam                                    # Skera output
├── fl.*.bam                                         # Lima demux BAMs
├── flnc.*.bam                                       # Refine FLNC BAMs
├── clustered.*.transcripts.bam                      # Cluster transcript BAMs
├── mapped.*.bam                                     # PBMM2 aligned BAMs
├── collapse_isoforms.*.gff                          # Collapse isoform models
├── collapse_isoforms.*.fasta                        # Isoform sequences
├── collapse_isoforms.*.flnc_count.txt              # Quantification
├── pigeon.*_classification.txt                      # Classifications
├── pigeon.*_junctions.txt                          # Junction info
├── pigeon.*.filtered_lite_classification.txt       # Filtered classifications
├── collapse_isoforms.*.sorted.filtered_lite.gff   # Final filtered isoforms
└── pigeon.*.saturation.txt                         # Saturation reports
```

## 🔧 Troubleshooting

### Common Issues & Solutions

#### Pipeline Fails at Specific Step

**Problem**: Workflow stops with error message  
**Solution**:
1. Check the CWL terminal output for the exact error
2. Examine log files in `.cwl-out/*/` or `.cwl-tmp/*/stderr.txt`
3. Review step-specific logs (e.g., `skera.log`, `lima-isoseq.log`)
4. Look for tool-specific errors in the output directory

#### Out of Memory Errors

**Problem**: Process killed due to insufficient memory  
**Solution**:
- Increase EC2 instance size (recommend r6i.4xlarge or larger)
- Reduce thread counts in `params/main_params.yml`
- Process smaller data subsets
- Enable swap space on EC2 instance

#### Missing or Incomplete Outputs

**Problem**: Expected files not in `outputs/kinnex_output/`  
**Solution**:
- Check if workflow completed successfully (exit code 0)
- Intermediate files are in `.cwl-out/*/` during execution
- CWL only copies outputs to final directory on **successful completion**
- Re-run the workflow after fixing any errors

#### Primers File Format Error

**Problem**: `ERROR: Barcode names must contain either '3p' or '5p' suffix!`  
**Solution**:
- Lima/Refine require primers with `_5p` and `_3p` suffixes
- Use `IsoSeq_v2_primers_12.fasta` for `lima_barcodes` parameter
- Skera can use simpler primer files like `mas8_primers.fasta`

#### Docker Permission Errors

**Problem**: Docker cannot access S3-mounted files  
**Solution**:
- Enable FUSE `user_allow_other` in `/etc/fuse.conf`
- Mount S3 with `--allow-other` flag
- Ensure Docker daemon is running with proper permissions

#### Reference File Issues

**Problem**: Reference genome or annotation errors  
**Solution**:
- Ensure reference genome is uncompressed or bgzip-compressed FASTA
- Verify GTF file follows standard format
- Check file paths are accessible to Docker containers
- Validate file integrity with `samtools faidx` or `gtf_validator`

### Validation & Testing

#### Validate Workflow Syntax

```bash
# Check CWL syntax before running
cwltool --validate main_workflow.cwl
```

#### Test with Small Dataset

```bash
# Use 1% sampled data for testing
cwltool \
  --outdir outputs/test_run \
  main_workflow.cwl \
  params/test_params.yml
```

#### Check Individual Steps

Run subworkflows independently to isolate issues:

```bash
# Test skera only
cwltool workflows/skera.cwl params/skera_test.yml

# Test lima only
cwltool workflows/lima_isoseq_run.cwl params/lima_isoseq_test.yml
```

## ⚙️ Resource Requirements

### Minimum Configuration

For testing with 1% sampled data:
- **CPU**: 8 cores
- **RAM**: 32 GB
- **Storage**: 100 GB
- **EC2 Instance**: t3.2xlarge or equivalent

### Recommended Configuration

For full production datasets:
- **CPU**: 16+ cores
- **RAM**: 64-128 GB
- **Storage**: 500 GB - 1 TB
- **EC2 Instance**: r6i.4xlarge or r6i.8xlarge

### Factors Affecting Requirements

- **Number of input reads**: More reads = more memory/time
- **Number of barcodes/samples**: Scales linearly with sample count
- **Genome size**: Larger genomes require more alignment time
- **Transcriptome complexity**: Higher diversity increases clustering time

### Storage Considerations

**Temporary files** (`.cwl-tmp/`, `.cwl-out/`):
- Can grow to 2-3x input data size
- Cleaned after successful completion with cleanup commands
- Keep during debugging with `--leave-tmpdir`

**Final outputs**:
- Typically 1-2x input data size
- Includes BAMs, GFFs, FASTAs, and reports

**Recommended**: Use EC2 instances with EBS volumes sized appropriately

## 🚀 Future Plans

### Cavatica Platform Integration

This pipeline is designed to be portable to the Cavatica platform:
- CWL workflows are fully compatible with Cavatica's execution environment
- Docker containers can be registered in Cavatica's container registry
- Input/output handling works seamlessly with Cavatica's file system
- Coming soon: Pre-configured Cavatica app with optimized settings

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
