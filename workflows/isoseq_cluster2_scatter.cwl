cwlVersion: v1.2
class: Workflow

label: Scatter isoseq cluster2 across multiple FLNC BAMs
requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  flnc_dir: Directory
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: INFO
  singletons:
    type: boolean?
    default: false
  sort_threads:
    type: int?
    doc: Number of sorting threads per BAM file. Defaults to -j
  write_bam_suffix:
    type: string?
    doc: If provided, will create annotated BAM with this suffix

steps:
  list_flnc_bams:
    run: ../tools/list_files_by_pattern.cwl
    in:
      dir: flnc_dir
      pattern:
        valueFrom: "^flnc\\..*\\.bam$" # JavaScript regex pattern to match BAM files
    out: [files]

  cluster_each:
    run: ../tools/isoseq_cluster2.cwl
    in:
      flnc_input: list_flnc_bams/files
      transcripts_bam:
        valueFrom:  $("clustered." + inputs.flnc_input.basename.replace(/^flnc\./,'').replace(/\.bam$/,'') + ".transcripts.bam")
      threads: threads
      log_level: log_level
      log_file:
        valueFrom: $("clustered." + inputs.flnc_input.basename.replace(/^flnc\./,'').replace(/\.bam$/,'') + ".isoseq-cluster2.log")
      singletons: singletons
      sort_threads: sort_threads
      write_bam: write_bam_suffix

    out: [transcripts_output, transcripts_bam_pbi, singletons_output, annotated_bam, report_csv]
    scatter: flnc_input
    scatterMethod: dotproduct

outputs:
  transcripts_bams:
    type: File[]
    outputSource: cluster_each/transcripts_output
  transcripts_bam_pbis:
    type: File[]?
    outputSource: cluster_each/transcripts_bam_pbi
  singletons_outputs:
    type: File[]?
    outputSource: cluster_each/singletons_output
  annotated_bams:
    type: File[]?
    outputSource: cluster_each/annotated_bam
  report_csvs:
    type: File[]?
    outputSource: cluster_each/report_csv
