cwlVersion: v1.2
class: Workflow
label: Scatter uLTRA alignment across clustered transcript BAMs

requirements:
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  reference: File
  annotation_gtf: File
  transcript_bams:
    type: File[]
  threads:
    type: int?
    default: 32
  sort_threads:
    type: int?
    default: 4
  index_thinning:
    type: int?

steps:
  sort_annotation:
    run: ../tools/sort_gtf.cwl
    in:
      annotation_gtf: annotation_gtf
      out_gtf:
        valueFrom: annotation.coordinate_sorted.gtf
    out: [sorted_gtf]
  build_index:
    run: ../tools/ultra_index.cwl
    in:
      reference: reference
      annotation_gtf: sort_annotation/sorted_gtf
      out_dir:
        valueFrom: ultra_index
      thinning: index_thinning
    out: [index_dir]
  align_each:
    run: ultra_isoseq_align_one.cwl
    in:
      reference: reference
      index_dir: build_index/index_dir
      in_bam: transcript_bams
      out_bam:
        valueFrom: $(inputs.in_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.ultra.bam')
      threads: threads
      sort_threads: sort_threads
      log_file:
        valueFrom: $(inputs.in_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.ultra.log')
    out: [mapped_bam, bam_index, log_file_output]
    scatter: in_bam
    scatterMethod: dotproduct

outputs:
  mapped_bams:
    type: File[]
    outputSource: align_each/mapped_bam
  bam_indices:
    type: File[]
    outputSource: align_each/bam_index
  log_files:
    type: File[]
    outputSource: align_each/log_file_output
