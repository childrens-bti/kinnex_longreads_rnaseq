cwlVersion: v1.2
class: CommandLineTool
label: Align FASTQ reads with uLTRA Iso-Seq parameters

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 32)"
    ramMin: 64000

baseCommand: [uLTRA, align]

inputs:
  reference:
    type: File
    doc: Reference genome FASTA
    inputBinding:
      position: 1
  reads_fastq:
    type: File
    doc: FASTQ reads converted from a clustered transcript BAM
    inputBinding:
      position: 2
  index_dir:
    type: Directory
    doc: Index produced by ultra_index.cwl
    inputBinding:
      prefix: --index
      position: 0
  out_dir:
    type: string
    default: ultra_output
    inputBinding:
      position: 3
  prefix:
    type: string
    default: aligned
    inputBinding:
      prefix: --prefix
      position: 0
  threads:
    type: int?
    default: 32
    inputBinding:
      prefix: --t
      position: 0
  isoseq:
    type: boolean
    default: true
    inputBinding:
      prefix: --isoseq
      position: 0
  log_file:
    type: string
    default: ultra_align.log

stderr: $(inputs.log_file)

outputs:
  mapped_sam:
    type: File
    outputBinding:
      glob: $(inputs.out_dir + '/' + inputs.prefix + '.sam')
  log_file_output:
    type: File
    outputBinding:
      glob: $(inputs.log_file)
