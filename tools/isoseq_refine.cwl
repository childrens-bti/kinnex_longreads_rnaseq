cwlVersion: v1.2
class: CommandLineTool
label: Iso-Seq refine full-length detection

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 64000
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 16)"

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
    type: int?
    default: 0
    inputBinding:
      prefix: -j
  log_level:
    type: string?
    inputBinding:
      prefix: --log-level
  require_polya:
    type: boolean?
    default: true
    inputBinding:
      prefix: --require-polya

# Only ONE positional argument for the output filename (the FLNC BAM)
arguments:
  - position: 3
    valueFrom: $("flnc." + inputs.biosample_name + ".bam")

stderr: $("flnc." + inputs.biosample_name + ".refine.log")
outputs:
  out_flnc_bam:
    type: File
    outputBinding:
      glob: flnc.$(inputs.biosample_name).bam
    secondaryFiles:
      - pattern: .pbi
        required: false

  filter_summary_json:
    type: File?
    outputBinding:
      glob: flnc.$(inputs.biosample_name).filter_summary.report.json

  report_csv:
    type: File?
    outputBinding:
      glob: flnc.$(inputs.biosample_name).report.csv

