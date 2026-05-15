#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool
label: Merge Demultiplexed BAMs by Barcode

doc: |
  Merge demultiplexed BAM files from multiple SMRTcells by matching barcode names.
  
  This tool reorganizes a flat list of demux BAMs from multiple SMRTcells and merges
  BAMs with matching barcode names.
  
  Assumptions:
  - All BAM filenames contain a barcode identifier (e.g., "bc01", "bc02")
  - BAMs from different SMRTcells have identical barcode names
  - Same number of barcodes from each SMRTcell
  
  Example:
  Input:  [
    cell1_bc01.bam, cell1_bc02.bam, cell1_bc03.bam,
    cell2_bc01.bam, cell2_bc02.bam, cell2_bc03.bam
  ]
  
  Output: [
    SR011156_task001.fl.IsoSeqX_bc01_5p--IsoSeqX_3p.merged.bam,
    SR011156_task001.fl.IsoSeqX_bc02_5p--IsoSeqX_3p.merged.bam,
    SR011156_task001.fl.IsoSeqX_bc03_5p--IsoSeqX_3p.merged.bam
  ]
  (BA_XXXXX inserted after output_basename downstream by rename_bams_with_bioassay_id)

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0

inputs:
  demux_bams:
    type: File[]
    doc: |
      Flat array of demultiplexed BAM files from all SMRTcells.
      Will be matched and merged by barcode name.

  output_basename:
    type: string
    doc: Run-level basename to preserve in merged BAM filenames
  
  num_smrt_cells:
    type: int
    doc: Number of SMRTcells (expected BAMs per barcode)
  
  threads:
    type: int?
    default: 0
    doc: Number of threads for samtools merge

baseCommand: [python3, /scripts/utils/merge_by_barcode.py]

arguments:
  - valueFrom: |
      $(inputs.demux_bams.map(function(f) { return f.path; }).join(','))
    position: 1
  - valueFrom: $(inputs.output_basename)
    position: 2
  - valueFrom: $(inputs.num_smrt_cells)
    position: 3
  - valueFrom: $(inputs.threads)
    position: 4

outputs:
  merged_bams:
    type: File[]
    doc: Array of merged BAMs (one per barcode)
    outputBinding:
      glob: "*.merged.bam"

