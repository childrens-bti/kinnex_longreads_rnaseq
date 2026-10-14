cwlVersion: v1.2
class: CommandLineTool
label: Pigeon filter - Transcript classification filtering
doc: |
  Filter transcript classifications based on various quality criteria including
  poly-A detection, junction coverage, and distance to annotated 3' ends.

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 64000
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 16)"
  InitialWorkDirRequirement:
    listing:
      - $(inputs.classification_txt)
      - $(inputs.junctions_txt)
      - ${ if (inputs.isoforms_gff) { return inputs.isoforms_gff; } else { return null; } }

baseCommand: [pigeon, filter]

inputs:
  classification_txt:
    type: File
    doc: Classifications to filter
    inputBinding:
      position: 1
      valueFrom: $(self.basename)

  junctions_txt:
    type: File
    doc: Junctions file (companion to classification file, must be in same directory)

  # Input/Output Options
  isoforms_gff:
    type: File?
    doc: Isoforms GFF file to be filtered (produces sorted.filtered_lite.gff output)
    inputBinding:
      prefix: --isoforms
      valueFrom: $(self.basename)

  # Filter Settings
  polya_percent:
    type: float?
    default: 0.6
    doc: Adenine percentage at genomic 3' end to flag an isoform as intra-priming
    inputBinding:
      prefix: --polya-percent

  polya_run_length:
    type: int?
    default: 6
    doc: Continuous run-A length at genomic 3' end to flag an isoform as intra-priming
    inputBinding:
      prefix: --polya-run-length

  max_distance:
    type: int?
    default: 50
    doc: Maximum distance to an annotated 3' end to preserve as a valid 3' end
    inputBinding:
      prefix: --max-distance

  min_cov:
    type: int?
    default: 3
    doc: Minimum junction coverage for each isoform
    inputBinding:
      prefix: --min-cov

  mono_exon:
    type: boolean?
    default: false
    doc: Filter out all mono-exonic transcripts
    inputBinding:
      prefix: --mono-exon

  skip_junctions:
    type: boolean?
    default: false
    doc: Skip junctions.txt filtering
    inputBinding:
      prefix: --skip-junctions

  # General Options
  threads:
    type: int?
    default: 0
    doc: Number of threads to use, 0 means autodetection
    inputBinding:
      prefix: --num-threads

  log_level:
    type: string?
    default: WARN
    doc: Set log level
    inputBinding:
      prefix: --log-level

  log_file:
    type: string?
    doc: Log to a file, instead of stderr
    inputBinding:
      prefix: --log-file

outputs:
  filtered_classification_txt:
    type: File
    doc: Filtered classification file
    outputBinding:
      glob: "*.filtered_lite_classification.txt"

  filtered_junctions_txt:
    type: File
    doc: Filtered junctions file
    outputBinding:
      glob: "*.filtered_lite_junctions.txt"

  filtered_reasons_txt:
    type: File
    doc: Reasons for filtering each isoform
    outputBinding:
      glob: "*.filtered_lite_reasons.txt"

  filtered_gff:
    type: File?
    doc: Filtered isoforms GFF (only if --isoforms is used)
    outputBinding:
      glob: "*.sorted.filtered_lite.gff"

  filtered_report_json:
    type: File
    doc: Filtered classification report (JSON format)
    outputBinding:
      glob: "*.filtered.report.json"

  filtered_summary_txt:
    type: File
    doc: Filtered classification summary
    outputBinding:
      glob: "*.filtered.summary.txt"

  log_file_output:
    type: File?
    outputBinding:
      glob: "${ return inputs.log_file ? inputs.log_file : []; }"
