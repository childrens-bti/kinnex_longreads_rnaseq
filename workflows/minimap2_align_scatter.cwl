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
  bam_to_fastq:
    run: ../tools/samtools_fastq.cwl
    in:
      in_bam: transcript_bams
    out: [reads_fastq]
    scatter: in_bam
    scatterMethod: dotproduct
  align_each:
    run: ../tools/minimap2_junction_align.cwl
    in:
      reference: reference
      junction_bed: junction_bed/junction_bed
      reads_fastq: bam_to_fastq/reads_fastq
      source_bam: transcript_bams
      out_sam:
        valueFrom: $(inputs.source_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.minimap2.sam')
      seed_k: seed_k
      seed_w: seed_w
      threads: threads
      log_file:
        valueFrom: $(inputs.source_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.minimap2.log')
    out: [mapped_sam, log_file_output]
    scatter: [reads_fastq, source_bam]
    scatterMethod: dotproduct
  restore_tags:
    run: ../tools/restore_isoseq_tags.cwl
    in:
      source_bam: transcript_bams
      mapped_sam: align_each/mapped_sam
    out: [tagged_sam]
    scatter: [source_bam, mapped_sam]
    scatterMethod: dotproduct
  sort_each:
    run: ../tools/samtools_sort.cwl
    in:
      in_sam: restore_tags/tagged_sam
      source_bam: transcript_bams
      out_bam:
        valueFrom: $(inputs.source_bam.basename.replace(/\.bam$/, '').replace(/\.clustered\./, '.mapped.') + '.minimap2.bam')
      threads: sort_threads
    out: [sorted_bam]
    scatter: [in_sam, source_bam]
    scatterMethod: dotproduct
  index_each:
    run: ../tools/samtools_index.cwl
    in:
      in_bam: sort_each/sorted_bam
      out_bai:
        source: sort_each/sorted_bam
        valueFrom: $(self.basename + '.bai')
      threads: sort_threads
    out: [bam_index]
    scatter: [in_bam, out_bai]
    scatterMethod: dotproduct

outputs:
  mapped_bams:
    type: File[]
    outputSource: sort_each/sorted_bam
  bam_indices:
    type: File[]
    outputSource: index_each/bam_index
  log_files:
    type: File[]
    outputSource: align_each/log_file_output
