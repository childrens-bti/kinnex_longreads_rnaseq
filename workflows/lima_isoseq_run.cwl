cwlVersion: v1.2
class: Workflow

label: Run lima --isoseq on segmented dataset

requirements:
  InlineJavascriptRequirement: {}

inputs:
  in_dataset: File
  barcodes: File
  out_prefix:
    type: string
    default: fl
  threads:
    type: int
    default: 0
  log_level:
    type: string
    default: INFO
  log_file:
    type: string
    default: lima-isoseq.log

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
    out: [out_dataset, demux_bams, demux_bam_pbis, counts, report, summary, lima_log]

outputs:
  out_dataset:
    type: File
    outputSource: lima_isoseq/out_dataset
  demux_bams:
    type: File[]?
    outputSource: lima_isoseq/demux_bams
  demux_bam_pbis:
    type: File[]?
    outputSource: lima_isoseq/demux_bam_pbis
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
