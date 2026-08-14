cwlVersion: v1.2
class: CommandLineTool
label: Build uLTRA annotation index

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: 1
    ramMin: 64000

baseCommand: [uLTRA, index]

inputs:
  reference:
    type: File
    doc: Reference genome FASTA
    inputBinding:
      position: 1
  annotation_gtf:
    type: File
    doc: Reference annotation GTF containing gene and transcript features
    inputBinding:
      position: 2
  out_dir:
    type: string
    default: ultra_index
    inputBinding:
      position: 3
  disable_infer:
    type: boolean
    default: true
    inputBinding:
      prefix: --disable_infer
      position: 4
  thinning:
    type: int?
    doc: Seed thinning level from 0 to 2
    inputBinding:
      prefix: --thinning
      position: 5

outputs:
  index_dir:
    type: Directory
    outputBinding:
      glob: $(inputs.out_dir)
