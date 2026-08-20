cwlVersion: v1.2
class: CommandLineTool
label: Minimap2 Iso-Seq alignment with annotated splice junctions

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 32)"
    ramMin: 32000
  InlineJavascriptRequirement: {}

baseCommand: [minimap2]
stdout: $(inputs.out_sam)
stderr: $(inputs.log_file)

arguments:
  - -a
  - -x
  - splice:hq
  - -u
  - f
  - --eqx
  - --secondary=no

inputs:
  reference:
    type: File
    doc: Reference genome FASTA
    inputBinding:
      position: 1
  reads_fastq:
    type: File
    doc: Clustered transcript sequences in FASTQ format
    inputBinding:
      position: 2
  junction_bed:
    type: File
    doc: Junction annotation in minimap2-compatible BED format
    inputBinding:
      prefix: --junc-bed
      position: 0
  seed_k:
    type: int?
    default: 15
    doc: Minimizer k-mer size. Matches the splice:hq preset default.
    inputBinding:
      prefix: -k
      position: 0
  seed_w:
    type: int?
    default: 5
    doc: Minimizer window size. Matches the splice:hq preset default.
    inputBinding:
      prefix: -w
      position: 0
  threads:
    type: int?
    default: 32
    inputBinding:
      prefix: -t
      position: 0
  out_sam:
    type: string
    default: mapped.minimap2.sam
  log_file:
    type: string
    default: minimap2_align.log

outputs:
  mapped_sam:
    type: File
    outputBinding:
      glob: $(inputs.out_sam)
  log_file_output:
    type: File
    outputBinding:
      glob: $(inputs.log_file)
