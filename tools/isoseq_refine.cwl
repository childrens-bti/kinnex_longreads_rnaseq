cwlVersion: v1.2
class: CommandLineTool
label: Iso-Seq refine full-length detection
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [isoseq, refine]
inputs:
  in_bam:
    type: File
    inputBinding:
      position: 1
  primers_fa:
    type: File
    inputBinding:
      position: 2
  out_bam:
    type: string
    default: flnc-1.bam
    inputBinding:
      position: 3
  require_polya:
    type: boolean
    default: true
    inputBinding:
      prefix: --require-polya
stdout: isoseq_refine.stdout.txt
stderr: isoseq_refine.stderr.txt
outputs:
  flnc_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_bam)
