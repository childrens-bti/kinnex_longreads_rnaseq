cwlVersion: v1.2
class: Workflow
label: Align one clustered transcript BAM with annotation-guided minimap2

requirements:
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  reference: File
  junction_bed: File
  in_bam: File
  out_bam:
    type: string
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
  log_file:
    type: string

steps:
  bam_to_fastq:
    run: ../tools/samtools_fastq.cwl
    in:
      in_bam: in_bam
    out: [reads_fastq]
  align:
    run: ../tools/minimap2_junction_align.cwl
    in:
      reference: reference
      reads_fastq: bam_to_fastq/reads_fastq
      junction_bed: junction_bed
      seed_k: seed_k
      seed_w: seed_w
      threads: threads
      out_sam:
        valueFrom: $(self.replace(/\.bam$/, '.sam'))
      log_file: log_file
    out: [mapped_sam, log_file_output]
  sort:
    run: ../tools/samtools_sort.cwl
    in:
      in_sam: align/mapped_sam
      out_bam: out_bam
      threads: sort_threads
    out: [sorted_bam]
  index:
    run: ../tools/samtools_index.cwl
    in:
      in_bam: sort/sorted_bam
      out_bai:
        source: sort/sorted_bam
        valueFrom: $(self.basename + '.bai')
      threads: sort_threads
    out: [bam_index]

outputs:
  mapped_bam:
    type: File
    outputSource: sort/sorted_bam
  bam_index:
    type: File
    outputSource: index/bam_index
  log_file_output:
    type: File
    outputSource: align/log_file_output
