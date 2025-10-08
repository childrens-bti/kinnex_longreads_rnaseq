cwlVersion: v1.2
class: CommandLineTool
label: pbmm2 align ISOSEQ
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [pbmm2, align]
inputs:
  reference_fa:
    type: File
    inputBinding:
      position: 1
  transcripts_fa:
    type: File
    inputBinding:
      position: 2
  out_bam:
    type: string
    default: mapped-1.bam
    inputBinding:
      position: 3
  preset:
    type: string
    default: ISOSEQ
    inputBinding:
      prefix: --preset
  sort:
    type: boolean
    default: true
    inputBinding:
      prefix: --sort
stdout: pbmm2.stdout.txt
stderr: pbmm2.stderr.txt
outputs:
  mapped_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_bam)
