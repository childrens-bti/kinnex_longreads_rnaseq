cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  hifi_bam:
    type: File
    doc: HiFi BAM file (e.g., *bc*.bam)
    secondaryFiles:
      - required: false
        pattern: .pbi
  adapters_fa:
    type: File
    doc: Adapters FASTA (e.g., params/mas8_primers.fasta)
  out_prefix:
    type: string?
    default: segmented
  threads:
    type: int?
    default: 0
  use_dataset_xml:
    type: boolean?
    default: true
  log_level:
    type: string?
    default: INFO
  log_file:
    type: string?

steps:
  skera_split:
    run: ../tools/skera_split.cwl
    in:
      in_bam: hifi_bam
      adapters_fa: adapters_fa
      out_prefix: out_prefix
      threads: threads
      use_dataset_xml: use_dataset_xml
      log_level: log_level
      log_file: log_file
    out: [segmented_bam, non_passing_bam, segmented_dataset, summary_csv, ligations_csv, read_lengths_csv, adapters_csv_gz]

outputs:
  segmented_bam:
    type: File
    outputSource: skera_split/segmented_bam
  non_passing_bam:
    type: File
    outputSource: skera_split/non_passing_bam
  segmented_dataset:
    type: File?
    outputSource: skera_split/segmented_dataset
  summary_csv:
    type: File?
    outputSource: skera_split/summary_csv
  ligations_csv:
    type: File?
    outputSource: skera_split/ligations_csv
  read_lengths_csv:
    type: File?
    outputSource: skera_split/read_lengths_csv
  adapters_csv_gz:
    type: File?
    outputSource: skera_split/adapters_csv_gz
