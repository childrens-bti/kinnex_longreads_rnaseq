cwlVersion: v1.2
class: Workflow
label: Align one clustered transcript BAM with uLTRA

requirements:
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  reference: File
  index_dir: Directory
  in_bam: File
  out_bam: string
  threads:
    type: int?
    default: 32
  sort_threads:
    type: int?
    default: 4
  log_file: string

steps:
  bam_to_fastq:
    run: ../tools/samtools_fastq.cwl
    in:
      in_bam: in_bam
    out: [reads_fastq]
  align:
    run: ../tools/ultra_isoseq_align.cwl
    in:
      reference: reference
      reads_fastq: bam_to_fastq/reads_fastq
      index_dir: index_dir
      threads: threads
      out_dir:
        valueFrom: ultra_output
      prefix:
        valueFrom: aligned
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
