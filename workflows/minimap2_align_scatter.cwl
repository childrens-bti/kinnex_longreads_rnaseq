cwlVersion: v1.2
class: Workflow
label: Scatter annotation-guided minimap2 alignment across clustered transcript BAMs

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
  alignment_method:
    type: string?
    default: minimap2
    doc: Main-workflow selector; unused by this alignment subworkflow.
  seed_k:
    type: int?
    default: 15
  seed_w:
    type: int?
    default: 5
  threads:
    type: int?
    default: 32
  sort_threads:
    type: int?
    default: 4

steps:
  junction_bed:
    run: ../tools/gtf_to_junction_bed.cwl
    in:
      annotation_gtf: annotation_gtf
      out_bed:
        valueFrom: annotation.junctions.bed
    out: [junction_bed]
  align_each:
    run: minimap2_align_one.cwl
    in:
      reference: reference
      junction_bed: junction_bed/junction_bed
      in_bam: transcript_bams
      out_bam:
        valueFrom: $(inputs.in_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.minimap2.bam')
      seed_k: seed_k
      seed_w: seed_w
      threads: threads
      sort_threads: sort_threads
      log_file:
        valueFrom: $(inputs.in_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.minimap2.log')
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
