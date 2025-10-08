cwlVersion: v1.2
class: CommandLineTool
label: Iso-Seq cluster2 consensus
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [isoseq, cluster2]
inputs:
  flnc_bam:
    type: File
    inputBinding:
      position: 1
  out_fasta:
    type: string
    default: transcripts-1.fasta
    inputBinding:
      position: 2
  verbose:
    type: boolean
    default: true
    inputBinding:
      prefix: --verbose
stdout: isoseq_cluster2.stdout.txt
stderr: isoseq_cluster2.stderr.txt
outputs:
  transcripts_fa:
    type: File
    outputBinding:
      glob: $(inputs.out_fasta)
