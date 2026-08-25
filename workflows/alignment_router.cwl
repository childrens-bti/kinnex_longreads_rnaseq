cwlVersion: v1.2
class: Workflow
label: Select and run one long-read alignment method

requirements:
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  reference: File
  annotation_gtf: File
  transcript_bams:
    type: File[]
  alignment_method:
    type: Any

  pbmm2_preset:
    type: string?
    default: ISOSEQ
  pbmm2_seed_k:
    type: int?
    default: 15
  pbmm2_seed_w:
    type: int?
    default: 5
  pbmm2_threads:
    type: int?
    default: 36
  pbmm2_sort:
    type: boolean?
    default: true
  pbmm2_bam_index:
    type: string?
  pbmm2_min_gap_comp_id_perc:
    type: float?
    default: 95.0
  log_level:
    type: string?
    default: INFO

  minimap2_seed_k:
    type: int?
    default: 15
  minimap2_seed_w:
    type: int?
    default: 5
  minimap2_threads:
    type: int?
    default: 36
  minimap2_sort_threads:
    type: int?
    default: 4

  ultra_threads:
    type: int?
    default: 36
  ultra_sort_threads:
    type: int?
    default: 4
  ultra_index_thinning:
    type: int?

steps:
  pbmm2:
    run: pbmm2_align_scatter.cwl
    in:
      alignment_method: alignment_method
      reference: reference
      transcript_bams: transcript_bams
      preset: pbmm2_preset
      seed_k: pbmm2_seed_k
      seed_w: pbmm2_seed_w
      threads: pbmm2_threads
      sort: pbmm2_sort
      bam_index: pbmm2_bam_index
      min_gap_comp_id_perc: pbmm2_min_gap_comp_id_perc
      log_level: log_level
    out: [mapped_bams, bam_indices, log_files]
    when: $(inputs.alignment_method === 'pbmm2')

  minimap2:
    run: minimap2_align_scatter.cwl
    in:
      alignment_method: alignment_method
      reference: reference
      annotation_gtf: annotation_gtf
      transcript_bams: transcript_bams
      seed_k: minimap2_seed_k
      seed_w: minimap2_seed_w
      threads: minimap2_threads
      sort_threads: minimap2_sort_threads
    out: [mapped_bams, bam_indices, log_files]
    when: $(inputs.alignment_method === 'minimap2')

  ultra:
    run: ultra_isoseq_align_scatter.cwl
    in:
      alignment_method: alignment_method
      reference: reference
      annotation_gtf: annotation_gtf
      transcript_bams: transcript_bams
      threads: ultra_threads
      sort_threads: ultra_sort_threads
      index_thinning: ultra_index_thinning
    out: [mapped_bams, bam_indices, log_files]
    when: $(inputs.alignment_method === 'ultra')

  select_outputs:
    run: select_alignment_outputs.cwl
    in:
      alignment_method: alignment_method
      pbmm2_mapped_bams: pbmm2/mapped_bams
      pbmm2_bam_indices: pbmm2/bam_indices
      pbmm2_log_files: pbmm2/log_files
      minimap2_mapped_bams: minimap2/mapped_bams
      minimap2_bam_indices: minimap2/bam_indices
      minimap2_log_files: minimap2/log_files
      ultra_mapped_bams: ultra/mapped_bams
      ultra_bam_indices: ultra/bam_indices
      ultra_log_files: ultra/log_files
    out: [mapped_bams, bam_indices, log_files]

outputs:
  mapped_bams:
    type: File[]
    outputSource: select_outputs/mapped_bams
  bam_indices:
    type: File[]?
    outputSource: select_outputs/bam_indices
  log_files:
    type: File[]?
    outputSource: select_outputs/log_files
