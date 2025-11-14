cwlVersion: v1.2
class: Workflow

label: Run lima --isoseq on segmented dataset

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  in_dataset: File
  barcodes: File
  barcode_mapping:
    type: File
    doc: "JSON mapping file from parse_manifest (barcode -> Bioassay_ID)"
  out_prefix:
    type: string?
    default: fl
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: INFO
  log_file:
    type: string?
    default: fl.lima-isoseq.log

steps:
  lima_isoseq:
    run: ../tools/lima_isoseq.cwl
    in:
      in_dataset: in_dataset
      barcodes: barcodes
      out_prefix: out_prefix
      threads: threads
      log_level: log_level
      log_file: log_file
      isoseq_mode:
        default: true
      peek_guess:
        default: true
      ignore_xml_biosamples:
        default: true
      overwrite_biosample_names:
        default: true
    out: [out_dataset, demux_bams, counts, report, summary, lima_log]

  rename_with_bioassay_id:
    run: ../tools/rename_bams_with_bioassay_id.cwl
    in:
      input_bams:
        source: lima_isoseq/demux_bams
      barcode_mapping:
        source: barcode_mapping
    out: [renamed_bams]

outputs:
  out_dataset:
    type: File
    outputSource: lima_isoseq/out_dataset
  demux_bams:
    type: File[]
    outputSource: rename_with_bioassay_id/renamed_bams
  counts:
    type: File?
    outputSource: lima_isoseq/counts
  report:
    type: File?
    outputSource: lima_isoseq/report
  summary:
    type: File?
    outputSource: lima_isoseq/summary
  lima_log:
    type: File?
    outputSource: lima_isoseq/lima_log
