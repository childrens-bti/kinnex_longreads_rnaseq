cwlVersion: v1.2
class: CommandLineTool
label: Rename BAM files with Bioassay ID prefix

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.input_bams)
        writable: true

baseCommand: [python3, /scripts/utils/rename_bams.py]

inputs:
  input_bams:
    type: File[]
    secondaryFiles:
      - pattern: .pbi
        required: false
  barcode_mapping:
    type: File
    inputBinding:
      position: 1

outputs:
  renamed_bams:
    type: File[]
    outputBinding:
      glob: "*.bam"
    secondaryFiles:
      - pattern: .pbi
        required: false
