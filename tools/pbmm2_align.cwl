cwlVersion: v1.2
class: CommandLineTool
label: pbmm2 align (ISOSEQ preset)
requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  ShellCommandRequirement: {}
baseCommand: [pbmm2, align]

inputs:
  reference:
    type: File
    doc: Reference FASTA, ReferenceSet XML, or prebuilt .mmi index
    inputBinding:
      position: 1
  in_bam:
    type: File
    doc: Input FLNC BAM (from isoseq refine/cluster2)
    inputBinding:
      position: 2
  out_bam:
    type: string
    default: mapped.bam
    doc: Output aligned BAM
    inputBinding:
      position: 3
  preset:
    type: string
    default: ISOSEQ
    inputBinding:
      prefix: --preset
  threads:
    type: int
    default: 0
    inputBinding:
      prefix: -j
  log_level:
    type: string?
    inputBinding:
      prefix: --log-level
  log_file:
    type: string?
    inputBinding:
      prefix: --log-file
  sort:
    type: boolean
    default: true
    inputBinding:
      prefix: --sort
  bam_index:
    type: string?
    doc: BAM index type for sorted output (NONE, BAI, CSI)
    inputBinding:
      prefix: --bam-index
  min_gap_comp_id_perc:
    type: float
    default: 95.0
    doc: Minimum gap-compressed sequence identity in percent
    inputBinding:
      prefix: --min-gap-comp-id-perc

outputs:
  mapped_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_bam)
    secondaryFiles:
      - .bai?
  log_file:
    type: File?
    outputBinding:
      glob: $(inputs.log_file)
