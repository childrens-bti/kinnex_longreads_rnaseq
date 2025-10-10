cwlVersion: v1.2
class: Workflow
label: Scatter isoseq refine across demultiplexed BAMs

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  demux_dir: Directory
  barcodes: File
  threads:
    type: int
    default: 0
  log_level:
    type: string
    default: INFO
  require_polya:
    type: boolean
    default: true

steps:
  list_bams:
    run: ../tools/list_bams_expr.cwl
    in:
      demux_dir: demux_dir
    out: [bam_files]

  refine_each:
    run: ../tools/isoseq_refine.cwl
    in:
      in_dataset: list_bams/bam_files
      barcodes: barcodes
      biosample_name:
        valueFrom: $(inputs.in_dataset.nameroot.replace(/^fl\./,''))
      threads: threads
      log_level: log_level
      require_polya: require_polya
    scatter: in_dataset         # scatter over the BAMs
    out: [out_flnc_bam, filter_summary_json, report_csv, refine_log]

outputs:
  out_flnc_bams:
    type: File[]
    outputSource: refine_each/out_flnc_bam
  filter_summaries:
    type: File[]?
    outputSource: refine_each/filter_summary_json
  reports:
    type: File[]?
    outputSource: refine_each/report_csv
  refine_logs:
    type: File[]?
    outputSource: refine_each/refine_log
