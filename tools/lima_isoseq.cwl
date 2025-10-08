cwlVersion: v1.2
class: CommandLineTool
label: Primer detection (lima --isoseq)
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [lima]
inputs:
  segmented_bam:
    type: File
    inputBinding:
      position: 1
  primers_fa:
    type: File
    inputBinding:
      position: 2
  out_bam:
    type: string
    default: fl_transcripts.bam
    inputBinding:
      position: 3
  isoseq_mode:
    type: boolean
    default: true
    inputBinding:
      prefix: --isoseq
  peek_guess:
    type: boolean
    default: true
    inputBinding:
      prefix: --peek-guess
stdout: lima.stdout.txt
stderr: lima.stderr.txt
outputs:
  demux_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_bam)
