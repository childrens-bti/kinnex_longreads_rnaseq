cwlVersion: v1.2
class: Workflow

label: Scatter isoseq cluster2 across multiple FLNC BAMs
requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  flnc_bams:
    type: File[]
    secondaryFiles:
      - pattern: .pbi
        required: false
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: INFO
  singletons:
    type: boolean?
    default: false

steps:
  cluster_each:
    run: ../tools/isoseq_cluster2.cwl
    in:
      flnc_input: flnc_bams
      transcripts_bam:
        valueFrom:  $("clustered." + inputs.flnc_input.basename.replace(/^flnc\./,'').replace(/\.bam$/,'') + ".transcripts.bam")
      threads: threads
      log_level: log_level
      log_file:
        valueFrom: $("clustered." + inputs.flnc_input.basename.replace(/^flnc\./,'').replace(/\.bam$/,'') + ".isoseq-cluster2.log")
      singletons: singletons

    out: [transcripts_output, singletons_output, annotated_bam, report_csv]
    scatter: flnc_input
    scatterMethod: dotproduct

outputs:
  transcripts_bams:
    type: File[]
    outputSource: cluster_each/transcripts_output
  singletons_outputs:
    type: File[]?
    outputSource: cluster_each/singletons_output
  annotated_bams:
    type: File[]?
    outputSource: cluster_each/annotated_bam
  report_csvs:
    type: File[]?
    outputSource: cluster_each/report_csv
