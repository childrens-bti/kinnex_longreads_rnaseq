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
    valueFrom: $(inputs.in_dataset.basename.replace(/\.bam$/, '').replace(/\.fl\./, '.flnc.') + '.bam')

stderr: $(inputs.in_dataset.basename.replace(/\.bam$/, '').replace(/\.fl\./, '.flnc.') + '.refine.log')

outputs:
  out_flnc_bam:
    type: File
    outputBinding:
      glob: $(inputs.in_dataset.basename.replace(/\.bam$/, '').replace(/\.fl\./, '.flnc.') + '.bam')
    secondaryFiles:
      - pattern: .pbi
        required: false

  filter_summary_json:
    type: File?
    outputBinding:
      glob: $(inputs.in_dataset.basename.replace(/\.bam$/, '').replace(/\.fl\./, '.flnc.') + '.filter_summary.report.json')

  report_csv:
    type: File?
    outputBinding:
      glob: $(inputs.in_dataset.basename.replace(/\.bam$/, '').replace(/\.fl\./, '.flnc.') + '.report.csv')

