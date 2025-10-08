cwlVersion: v1.2
class: CommandLineTool
label: Iso-Seq collapse
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [isoseq, collapse]
inputs:
  mapped_bam:
    type: File
    inputBinding:
      position: 1
  out_gff:
    type: string
    default: collapse_isoforms-1.gff
    inputBinding:
      position: 2
stdout: isoseq_collapse.stdout.txt
stderr: isoseq_collapse.stderr.txt
outputs:
  collapse_gff:
    type: File
    outputBinding:
      glob: $(inputs.out_gff)
