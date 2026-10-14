cwlVersion: v1.2
class: CommandLineTool
label: Convert unpaired transcript BAM to FASTQ

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 2)"
    ramMin: 4096
  InlineJavascriptRequirement: {}

baseCommand: [samtools, fastq]

arguments:
  - "-n"
  - "-1"
  - "/dev/null"
  - "-2"
  - "/dev/null"
  - "-s"
  - "/dev/null"

inputs:
  in_bam:
    type: File
    doc: Unpaired clustered transcript BAM
    inputBinding:
      position: 1
  out_fastq:
    type: string
    default: transcripts.fastq
    inputBinding:
      prefix: "-0"
      position: 0
  threads:
    type: int?
    default: 2
    inputBinding:
      prefix: "-@"
      position: 0

outputs:
  reads_fastq:
    type: File
    outputBinding:
      glob: $(inputs.out_fastq)
