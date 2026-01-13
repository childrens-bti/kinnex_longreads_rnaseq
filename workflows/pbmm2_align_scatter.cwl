cwlVersion: v1.2
class: Workflow

label: Scatter pbmm2 align (ISOSEQ preset) across multiple BAMs

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  reference: File
  transcript_bams:
    type: File[]
  preset:
    type: string?
    default: ISOSEQ
  threads:
    type: int?
    default: 0
  sort:
    type: boolean?
    default: true
  bam_index:
    type: string?
    doc: BAM index type for sorted output (NONE, BAI, CSI)
  min_gap_comp_id_perc:
    type: float?
    default: 95.0
  log_level:
    type: string?
    default: INFO

steps:
  align_each:
    run: ../tools/pbmm2_align.cwl
    in:
      reference: reference
      in_bam: transcript_bams
      out_bam:
        valueFrom: $(inputs.in_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.bam')
      preset: preset
      threads: threads
      sort: sort
      bam_index:
        source: bam_index
      min_gap_comp_id_perc: min_gap_comp_id_perc
      log_level: log_level
      log_file:
        valueFrom: $(inputs.in_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.pbmm2.log')
    out: [mapped_bam, log_file_output]
    scatter: in_bam
    scatterMethod: dotproduct

outputs:
  mapped_bams:
    type: File[]
    outputSource: align_each/mapped_bam
  log_files:
    type: File[]?
    outputSource: align_each/log_file_output
