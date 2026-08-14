cwlVersion: v1.2
class: CommandLineTool
label: Index BAM

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 4)"
    ramMin: 4096
  InlineJavascriptRequirement: {}

baseCommand: [samtools, index]

inputs:
  in_bam:
    type: File
    inputBinding:
      position: 1
  out_bai:
    type: string
    default: mapped.bam.bai
    inputBinding:
      position: 2
  threads:
    type: int?
    default: 4
    inputBinding:
      prefix: -@
      position: 0

outputs:
  bam_index:
    type: File
    outputBinding:
      glob: $(inputs.out_bai)
