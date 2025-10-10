cwlVersion: v1.2
class: CommandLineTool
label: Iso-Seq refine full-length detection

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/chaodi/kinnex_longreads:v1.0
  ShellCommandRequirement: {}

baseCommand: [isoseq, refine]

inputs:
  in_dataset:
    type: File
    doc: Input dataset (ConsensusReadSet XML, FOFN, or BAM)
    inputBinding:
      position: 1
  barcodes:
    type: File
    doc: Barcode/Primer FASTA or BarcodeSet XML
    inputBinding:
      position: 2
  biosample_name:
    type: string
  threads:
    type: int
    default: 0
    inputBinding:
      prefix: -j
  log_level:
    type: string?
    inputBinding:
      prefix: --log-level
  require_polya:
    type: boolean
    default: true
    inputBinding:
      prefix: --require-polya

# Only ONE positional argument for the output filename (the FLNC BAM)
arguments:
  - position: 3
    valueFrom: $("flnc." + inputs.biosample_name + ".bam")

stderr: $(inputs.biosample_name.replace(/\.bam$/, '.refine.log'))
outputs:
  out_flnc_bam:
    type: File
    outputBinding:
      glob: flnc.$(inputs.biosample_name).bam

  filter_summary_json:
    type: File?
    outputBinding:
      glob: flnc.$(inputs.biosample_name).filter_summary.json

  report_csv:
    type: File?
    outputBinding:
      glob: flnc.$(inputs.biosample_name).report.csv

  refine_log:
    type: File?
    outputBinding:
      glob: flnc.$(inputs.biosample_name).refine.log
