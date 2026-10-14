cwlVersion: v1.2
class: CommandLineTool
label: Sort SAM alignment into BAM

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 4)"
    ramMin: 16000
  InlineJavascriptRequirement: {}

baseCommand: [samtools, sort]

inputs:
  in_sam:
    type: File
    inputBinding:
      position: 1
  out_bam:
    type: string
    default: mapped.bam
    inputBinding:
      prefix: -o
      position: 0
  threads:
    type: int?
    default: 4
    inputBinding:
      prefix: -@
      position: 0

outputs:
  sorted_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_bam)
