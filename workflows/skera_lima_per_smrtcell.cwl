#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
label: Single SMRTcell Processing (Skera + Lima)

doc: |
  Sub-workflow for processing a single SMRTcell through Skera segmentation
  and Lima demultiplexing. Used internally by multi-SMRTcell pipelines.
  
  Input: Single HiFi BAM from one SMRTcell
  Output: Segmented BAM and per-barcode demultiplexed BAMs

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  hifi_bam:
    type: File
    doc: HiFi BAM file from a single SMRTcell
    secondaryFiles:
      - required: false
        pattern: .pbi
  
  adapters_fa:
    type: File
    doc: Adapters FASTA file
  
  lima_barcodes:
    type: File
    doc: Barcode/Primer FASTA for demultiplexing
  
  out_prefix:
    type: string
    doc: Output prefix for this SMRTcell
  
  skera_threads:
    type: int?
    default: 0
  
  skera_use_dataset_xml:
    type: boolean?
    default: true
  
  lima_threads:
    type: int?
    default: 0
  
  log_level:
    type: string?
    default: INFO

steps:
  skera:
    run: ../tools/skera_split.cwl
    in:
      in_bam: hifi_bam
      adapters_fa: adapters_fa
      out_prefix: out_prefix
      threads: skera_threads
      use_dataset_xml: skera_use_dataset_xml
      log_level: log_level
    out: [segmented_bam, non_passing_bam, segmented_dataset, summary_csv, ligations_csv, read_lengths_csv, adapters_csv_gz]

  lima:
    run: ../tools/lima_isoseq.cwl
    in:
      in_dataset: skera/segmented_bam
      barcodes: lima_barcodes
      out_prefix: out_prefix
      threads: lima_threads
      log_level: log_level
      log_file:
        valueFrom: $(inputs.out_prefix + ".fl.lima-isoseq.log")
      isoseq_mode:
        default: true
      peek_guess:
        default: true
      ignore_xml_biosamples:
        default: true
      overwrite_biosample_names:
        default: true
    out: [out_dataset, demux_bams, counts, report, summary, lima_log]

outputs:
  segmented_bam:
    type: File
    outputSource: skera/segmented_bam
  
  demux_bams:
    type: File[]
    outputSource: lima/demux_bams
  
  lima_counts:
    type: File?
    outputSource: lima/counts
  
  lima_report:
    type: File?
    outputSource: lima/report
  
  lima_summary:
    type: File?
    outputSource: lima/summary
