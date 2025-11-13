cwlVersion: v1.2
class: Workflow
label: Scatter isoseq refine across demultiplexed BAMs

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  demux_bams: File[]
  barcodes: File
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: INFO
  require_polya:
    type: boolean?
    default: true

steps:
  refine_each:
    run: ../tools/isoseq_refine.cwl
    in:
      in_dataset: demux_bams
      barcodes: barcodes
      biosample_name:
        valueFrom: $(inputs.in_dataset.nameroot.replace(/^fl\./,''))
      threads: threads
      log_level: log_level
      require_polya: require_polya
    scatter: in_dataset         # scatter over the BAMs
    out: [out_flnc_bam, out_flnc_bam_pbi, filter_summary_json, report_csv]

outputs:
  out_flnc_bams:
    type: File[]
    outputSource: refine_each/out_flnc_bam
  out_flnc_bam_pbis:
    type: File[]?
    outputSource: refine_each/out_flnc_bam_pbi
  filter_summaries:
    type: File[]?
    outputSource: refine_each/filter_summary_json
  reports:
    type: File[]?
    outputSource: refine_each/report_csv

