cwlVersion: v1.2
class: CommandLineTool
label: Pigeon classify - Transcript classification
requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 64000
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 16)"

baseCommand: [pigeon, classify]

inputs:
  isoforms_gff:
    type: File?
    doc: Isoforms to classify (from isoseq collapse)
    inputBinding:
      position: 1
  annotation_gtf:
    type: File?
    doc: Reference annotation GTF
    inputBinding:
      position: 2
  reference_fa:
    type: File?
    doc: Reference FASTA
    inputBinding:
      position: 3
  
  # Input/Output Options
  out_dir:
    type: string
    default: "."
    doc: Destination directory for all output files
    inputBinding:
      prefix: --out-dir
  out_prefix:
    type: string?
    doc: Prefix for all output files
    inputBinding:
      prefix: --out-prefix
  flnc_count:
    type: File?
    doc: IsoSeq FL count info from isoseq collapse (*.flnc_counts.txt)
    inputBinding:
      prefix: --flnc
  
  # General Options
  threads:
    type: int?
    default: 0
    doc: Number of threads to use, 0 means autodetection
    inputBinding:
      prefix: -j
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
  classification_txt:
    type: File
    outputBinding:
      glob: $(inputs.out_prefix)_classification.txt
  junctions_txt:
    type: File
    outputBinding:
      glob: $(inputs.out_prefix)_junctions.txt
  summary_txt:
    type: File
    outputBinding:
      glob: $(inputs.out_prefix).summary.txt
  report_json:
    type: File
    doc: JSON report file with detailed classification statistics
    outputBinding:
      glob: $(inputs.out_prefix).report.json
  log_file_output:
    type: File?
    outputBinding:
      glob: "${ return inputs.log_file ? inputs.log_file : []; }"
