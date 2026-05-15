# Kinnex Long-Read Sequencing Pipeline

This repository contains a comprehensive CWL-based workflow for processing Kinnex/MAS-Iso-Seq long-read sequencing data. The pipeline implements the complete PacBio Iso-Seq workflow from HiFi reads to final isoform characterization using open-source tools.

## 🔬 Pipeline Overview

The Kinnex/MAS-Iso-Seq pipeline processes long-read sequencing data through several key steps to identify and quantify transcript isoforms. All tools are available through PacBio's bioconda channel: [pbbioconda](https://github.com/PacificBiosciences/pbbioconda).

### Multi-SMRTcell Strategy

For one Kinnex library sequenced across multiple SMRTcells, the workflow avoids merging large raw HiFi BAMs. Instead, it:

1. Scatters over `hifi_bams` and runs Skera + Lima once per SMRTcell
2. Flattens the per-SMRTcell Lima outputs into one demux BAM list
3. Merges matching barcodes across SMRTcells into `output_basename.fl.<barcode>.merged.bam`
4. Inserts Bioassay IDs from `sample_manifest`, producing `output_basename.<Bioassay_ID>.fl.<barcode>.merged.bam`
5. Continues through refine, cluster, align, collapse, classify, filter, and report per merged sample

This keeps disk use much lower than upfront merging because only the smaller demultiplexed per-barcode BAMs are merged.

### 📊 Workflow Steps

#### 1. **HiFi Reads Input (provided by PacBio)**
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
- Removing [segmentation adapters](https://skera.how/adapters)
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
│   ├── merge_demux_bams_by_barcode.cwl
│   ├── parse_manifest.cwl
│   ├── pbmm2_align.cwl
│   ├── pigeon_classify.cwl
│   ├── pigeon_filter.cwl
│   ├── pigeon_prepare.cwl
│   ├── pigeon_report.cwl
│   ├── rename_bams_with_bioassay_id.cwl
│   └── skera_split.cwl
├── workflows/               # CWL workflows and subworkflows  
│   ├── isoseq_cluster2_scatter.cwl
│   ├── isoseq_collapse_scatter.cwl
│   ├── isoseq_refine_scatter.cwl
│   ├── pbmm2_align_scatter.cwl
│   ├── pigeon_classify_scatter.cwl
│   ├── pigeon_filter_report_scatter.cwl
│   └── skera_lima_per_smrtcell.cwl
├── scripts/                 # Utility scripts copied into the Docker image
│   └── utils/
│       ├── merge_by_barcode.py
│       └── rename_bams.py
├── data/                    # Input data (S3 mounts)
├── manifests/               # Manifest files 
├── params/                  # Workflow parameter files
│   ├── *_test.yml          # Test parameter files for each workflow
│   ├── multiple_smrt_cells_example.yml
│   └── kinnex_params.yml   # Main pipeline parameters
├── outputs/                 # Pipeline outputs
├── envs/                    # Conda environments
│   └── cwl_env.yml
├── run_data.sh              # Test execution scripts
├── kinnex_longreads.cwl     # Main workflow entry point
├── README.md
└── LICENSE
```

## 🎯 Quick Reference: Key Outputs

After successful workflow completion, find these primary files in the selected `--outdir`:

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
docker buildx build --platform linux/amd64 -t pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0 .
```

#### 2. Data Access from S3

Mount your S3 bucket to `data/` to access input data:

```bash
# Mount S3 bucket containing HiFi reads
bash mount_s3.sh your-bucket-name

# Mount S3 bucket containing reference files
bash mount_s3.sh bti-openaccess-us-east-1-prd-references

# Verify data is accessible
ls data/your-bucket-name/path-to-your-files
ls data/bti-openaccess-us-east-1-prd-references/
```

#### 3. Configure Pipeline Parameters

Edit `params/kinnex_params.yml` or start from `params/multiple_smrt_cells_example.yml` with your data paths:

```bash
nano params/multiple_smrt_cells_example.yml
```

**Required inputs to configure:**
```yaml
# CAVATICA naming convention: projectid_taskid
project_id: "SR011156"
output_basename: "SR011156_task001"

# Input data - direct file specification, one BAM per SMRTcell
hifi_bams:
  - class: File
    path: data/your-bucket-name/SMRTcell1/hifi_reads/sample_1.hifi_reads.bam
    secondaryFiles:
      - class: File
        path: data/your-bucket-name/SMRTcell1/hifi_reads/sample_1.hifi_reads.bam.pbi
  - class: File
    path: data/your-bucket-name/SMRTcell2/hifi_reads/sample_2.hifi_reads.bam
    secondaryFiles:
      - class: File
        path: data/your-bucket-name/SMRTcell2/hifi_reads/sample_2.hifi_reads.bam.pbi

# Sample manifest mapping Lima barcode filenames to Bioassay IDs
sample_manifest:
  class: File
  path: manifests/SR011156_barcode_manifest.tsv

# Adapters for segmentation (Skera)
adapters_fa:
  class: File
  path: data/references/mas8_primers.fasta

# Barcoded primers for demultiplexing (Lima) - must have _5p/_3p suffixes
lima_barcodes:
  class: File
  path: data/references/IsoSeq_v2_primers_12.fasta

# Reference genome
reference_fa:
  class: File
  path: data/reference/GRCh38.primary_assembly.genome.fa

# Gene annotation
annotation_gtf:
  class: File
  path: data/reference/gencode.v39.primary_assembly.annotation.gtf
```

The sample manifest must be a TSV with at least these columns:

```tsv
file_name	Bioassay_ID
fl.IsoSeqX_bc01_5p--IsoSeqX_3p.bam	BA_SR11156_01
fl.IsoSeqX_bc02_5p--IsoSeqX_3p.bam	BA_SR11156_02
```

**Optional parameters to tune:**
```yaml
# Thread settings (0 = auto-detect)
# Tools will use these defaults if not specified:
# - Cluster, Lima, PBMM2: 32 cores
# - Other tools: 16 cores
skera_threads: 0
lima_threads: 0
refine_threads: 0
cluster_threads: 0
pbmm2_threads: 0
collapse_threads: 0
classify_threads: 0
filter_threads: 0

# Resource requirements (automatically set)
# - All tools: 64GB RAM minimum
# - CPU cores scale with thread settings

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
  kinnex_longreads.cwl \
  params/multiple_smrt_cells_example.yml
```

**Command options explained:**
- `--leave-tmpdir`: Keep temporary files for debugging
- `--tmpdir-prefix ./.cwl-tmp/`: Store temp files locally
- `--tmp-outdir-prefix ./.cwl-out/`: Store intermediate outputs locally
- `--outdir outputs/kinnex_output`: Final output directory


#### 5. Test with Small Dataset and Check Individual Steps

- Use 0.1% sampled hifi reads (~80k), bam file can be downloaded to data/
```
aws s3 cp s3://bti-openaccess-us-east-1-bti-bfx/kinnex_longreads/data/sampled_hifi_reads/ data/sampled_hifi_reads/ --recursive --profile YOUR-CNH-SSO-PROFILE
```
- Run subworkflows independently to isolate issues:

```bash
bash run_data.sh
```

##### Monitor Progress

The pipeline executes the major stages below. Skera and Lima scatter over `hifi_bams`; downstream steps scatter over merged samples.

| Step | Tool | Description | 0.1% Sample Runtime* |
|------|------|-------------|---------------------|
| 0 | Parse Manifest | Build barcode-to-Bioassay_ID mapping | <1 min |
| 1 | Skera | Segment HiFi reads per SMRTcell | ~3 min per sampled BAM |
| 2 | Lima | Demultiplex by barcodes per SMRTcell | ~10 min per sampled BAM |
| 2b | Merge + Rename | Merge matching barcodes across SMRTcells, then insert Bioassay IDs | <5 min for sampled BAMs |
| 3 | IsoSeq Refine | Trim & filter FLNC reads | ~1 min |
| 4 | IsoSeq Cluster2 | Cluster into transcript models | ~12 min |
| 5 | PBMM2 | Align transcripts to reference | ~5 min |
| 6 | IsoSeq Collapse | Collapse into unique isoforms | <1 min |
| 7 | Pigeon Classify | Classify against annotation | ~1 min |
| 8 | Pigeon Filter & Report | Quality filter & reports | <1 min |

**Total time for 0.1% sample:** ~35 minutes (6 barcodes, ~80k HiFi reads)

*Based on actual run with 0.1% sampled HiFi reads (6 barcodes) on `m6i.4xlarge` EC2 instance (16 vCPUs, 64 GB RAM)  
**Full dataset projection (100% = 1000x data): Roughly 10-15 hours** depending on dataset complexity and clustering efficiency (not all steps scale linearly). Recommend testing with 1% and 10% samples to calibrate runtime estimates for your specific data.

#### 6. Output Collection

**Important:** CWL only copies outputs to the final `--outdir` upon **successful workflow completion**. 

- ✅ **During execution**: Intermediate outputs in `.cwl-out/*/` directories
- ✅ **On success**: All declared outputs copied to the selected `--outdir`
- ❌ **On failure**: Only completed steps' outputs may be in final directory

### 📋 Input Data Requirements

- **HiFi BAM files**: One or more high-fidelity consensus read BAMs in `hifi_bams`; use one entry per SMRTcell
- **PacBio BAM index files**: `.pbi` files are recommended for HiFi BAM inputs and should be provided as secondary files when running locally
- **Sample manifest**: TSV with `file_name` and `Bioassay_ID` columns. `file_name` should match Lima-style names such as `fl.IsoSeqX_bc01_5p--IsoSeqX_3p.bam`
- **Adapters FASTA** (Skera): Adapter sequences used for concatenation (e.g., `mas8_primers.fasta`)
- **Barcodes FASTA** (Lima): Barcoded primers with `_5p` and `_3p` suffixes (e.g., `IsoSeq_v2_primers_12.fasta`)
- **Reference genome**: Uncompressed FASTA
- **Annotation GTF**: Standard GTF format for gene annotations (uncompressed)

**Note:** PacBio tools use `.pbi` indexes, not `.bai` indexes. If you create sampled BAMs manually, generate `.pbi` files with `pbindex`.

### 📤 Pipeline Outputs

All outputs are in the selected `--outdir` upon successful workflow completion.

#### Step-by-Step Outputs

<details>
<summary><b>Step 1: Skera (Segmentation)</b></summary>

- **`<output_basename>.<smrtcell>.segmented.bam`** + `.pbi`: Successfully segmented reads
- **`<output_basename>.<smrtcell>.segmented.non_passing.bam`** + `.pbi`: Reads failing segmentation
- **`<output_basename>.<smrtcell>.segmented.consensusreadset.xml`**: Dataset XML (optional)
- **`<output_basename>.<smrtcell>.segmented.summary.csv`**: Segmentation statistics
- **`<output_basename>.<smrtcell>.segmented.ligations.csv`**: Ligation events
- **`<output_basename>.<smrtcell>.segmented.read_lengths.csv`**: Read length distributions
- **`<output_basename>.<smrtcell>.segmented.found_adapters.csv.gz`**: Adapter detection details

</details>

<details>
<summary><b>Step 2: Lima (Demultiplexing)</b></summary>

- **`<output_basename>.<smrtcell>.fl.IsoSeqX_bc##_5p--IsoSeqX_3p.bam`** + `.pbi`: Per-SMRTcell, per-barcode demultiplexed BAMs
- **`<output_basename>.<smrtcell>.fl.consensusreadset.xml`**: Lima output dataset XML
- **`<output_basename>.<smrtcell>.fl.lima.counts`**: Read counts per barcode
- **`<output_basename>.<smrtcell>.fl.lima.report`**: Detailed demultiplexing report
- **`<output_basename>.<smrtcell>.fl.lima.summary`**: Summary statistics
- **`<output_basename>.<smrtcell>.fl.lima-isoseq.log`**: Lima execution log

</details>

<details>
<summary><b>Step 2b: Merge + Bioassay ID Rename</b></summary>

- **`<output_basename>.fl.IsoSeqX_bc##_5p--IsoSeqX_3p.merged.bam`**: Barcode-matched BAM merged across all SMRTcells
- **`<output_basename>.<Bioassay_ID>.fl.IsoSeqX_bc##_5p--IsoSeqX_3p.merged.bam`**: Final merged demux BAM after Bioassay ID insertion

Example:

```text
SR011156_task001.BA_SR11156_01.fl.IsoSeqX_bc01_5p--IsoSeqX_3p.merged.bam
```

</details>

<details>
<summary><b>Step 3: IsoSeq Refine (FLNC Filtering)</b></summary>

- **`<output_basename>.<Bioassay_ID>.flnc.IsoSeqX_bc##_5p--IsoSeqX_3p.bam`** + `.pbi`: Full-length non-concatemer reads per barcode
- **`<output_basename>.<Bioassay_ID>.flnc.IsoSeqX_bc##_5p--IsoSeqX_3p.filter_summary.json`**: Filtering statistics
- **`<output_basename>.<Bioassay_ID>.flnc.IsoSeqX_bc##_5p--IsoSeqX_3p.report.csv`**: Per-barcode quality metrics

</details>

<details>
<summary><b>Step 4: IsoSeq Cluster2 (Clustering)</b></summary>

- **`<output_basename>.<Bioassay_ID>.clustered.IsoSeqX_bc##_5p--IsoSeqX_3p.transcripts.bam`** + `.pbi`: Consensus transcript sequences per sample
- **`<output_basename>.<Bioassay_ID>.clustered.IsoSeqX_bc##_5p--IsoSeqX_3p.transcripts.cluster_report.csv`**: Clustering statistics
- **`<output_basename>.<Bioassay_ID>.clustered.IsoSeqX_bc##_5p--IsoSeqX_3p.transcripts.singletons.bam`**: Singleton reads (if enabled)

</details>

<details>
<summary><b>Step 5: PBMM2 (Genome Alignment)</b></summary>

- **`<output_basename>.<Bioassay_ID>.mapped.IsoSeqX_bc##_5p--IsoSeqX_3p.bam`**: Genomic alignments per sample (sorted and indexed)
- **`pbmm2_align_*.log`**: Alignment log files

</details>

<details>
<summary><b>Step 6: IsoSeq Collapse (Isoform Collapsing)</b></summary>

- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.gff`**: Collapsed isoform models with genomic coordinates
- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.fasta`**: Isoform sequences
- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.flnc_count.txt`**: Read support per isoform (for quantification)
- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.group.txt`**: Read-to-isoform assignments
- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.read_stat.txt`**: Read statistics

</details>

<details>
<summary><b>Step 7: Pigeon Classify (Structural Classification)</b></summary>

- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p_classification.txt`**: Structural classification per transcript
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p_junctions.txt`**: Junction information and coverage
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.report.json`**: Classification statistics
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.summary.txt`**: Summary metrics
- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.sorted.gff`**: Sorted isoform annotations

</details>

<details>
<summary><b>Step 8: Pigeon Filter & Report (Quality Filtering)</b></summary>

**Recommended outputs for downstream analysis:**

- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered_lite_classification.txt`**: Quality-filtered classifications
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered_lite_junctions.txt`**: Filtered junction information
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered_lite_reasons.txt`**: Filtering reason codes
- **`<output_basename>.<Bioassay_ID>.collapse_isoforms.IsoSeqX_bc##_5p--IsoSeqX_3p.sorted.filtered_lite.gff`**: Quality-filtered isoform annotations (GFF)
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered.report.json`**: Comprehensive filtering statistics
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.filtered.summary.txt`**: Summary filtering metrics
- **`<output_basename>.<Bioassay_ID>.pigeon.IsoSeqX_bc##_5p--IsoSeqX_3p.saturation.txt`**: Transcript discovery saturation analysis

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
outputs/kinnex_output_or_multi_smrt_cells_example/
├── <output_basename>.<smrtcell>.segmented.*                         # Skera outputs per SMRTcell
├── <output_basename>.<smrtcell>.fl.*.bam                            # Lima demux BAMs per SMRTcell
├── <output_basename>.fl.*.merged.bam                                # Merged demux BAMs by barcode
├── <output_basename>.<Bioassay_ID>.fl.*.merged.bam                  # Merged demux BAMs after Bioassay ID insertion
├── <output_basename>.<Bioassay_ID>.flnc.*.bam                       # Refine FLNC BAMs
├── <output_basename>.<Bioassay_ID>.clustered.*.transcripts.bam      # Cluster transcript BAMs
├── <output_basename>.<Bioassay_ID>.mapped.*.bam                     # PBMM2 aligned BAMs
├── <output_basename>.<Bioassay_ID>.collapse_isoforms.*.gff          # Collapse isoform models
├── <output_basename>.<Bioassay_ID>.collapse_isoforms.*.fasta        # Isoform sequences
├── <output_basename>.<Bioassay_ID>.collapse_isoforms.*.flnc_count.txt # Quantification
├── <output_basename>.<Bioassay_ID>.pigeon.*_classification.txt      # Classifications
├── <output_basename>.<Bioassay_ID>.pigeon.*_junctions.txt           # Junction info
├── <output_basename>.<Bioassay_ID>.pigeon.*.filtered_lite_classification.txt # Filtered classifications
├── <output_basename>.<Bioassay_ID>.collapse_isoforms.*.sorted.filtered_lite.gff # Final filtered isoforms
└── <output_basename>.<Bioassay_ID>.pigeon.*.saturation.txt          # Saturation reports
```

## ⚙️ Resource Requirements

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


## 🚀 Cavatica Deployment

Validate and deploy the main workflow with `cwltool` and `sbpack`:

```bash
# Validate workflow
cwltool --validate kinnex_longreads.cwl

# Pack for deployment
cwltool --pack kinnex_longreads.cwl > kinnex_longreads.packed.cwl

# Deploy to Cavatica (requires sbpack)
sbpack cavatica your-division/your-project/workflow-name kinnex_longreads.cwl
```

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
