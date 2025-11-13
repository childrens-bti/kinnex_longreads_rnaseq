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
        valueFrom: |
          ${
            var name = inputs.in_dataset.nameroot || inputs.in_dataset.basename.replace(/\.bam$/, '');
            return name.replace(/^fl\./, '');
          }
      threads: threads
      log_level: log_level
      require_polya: require_polya
    scatter: in_dataset
    out: [out_flnc_bam, filter_summary_json, report_csv]

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

