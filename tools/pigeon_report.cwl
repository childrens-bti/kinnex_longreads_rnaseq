cwlVersion: v1.2
class: CommandLineTool
label: Pigeon report - Transcript reporting
doc: |
  Generate transcript reporting with subsampling analysis to assess 
  saturation and diversity of the isoform dataset.

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 64000
    coresMin: "$(inputs.threads > 0 ? inputs.threads : 16)"

baseCommand: [pigeon, report]

inputs:
  classification_txt:
    type: File
    doc: Classification file (typically the filtered classification file)
    inputBinding:
      position: 1

  output_filename:
    type: string
    default: "saturation.txt"
    doc: Output filename for subsampling report
    inputBinding:
      position: 2

  # Settings
  sub_sample_increment:
    type: int?
    default: 0
    doc: Number of reads between subsampling datapoints, 0 means auto-determined
    inputBinding:
      prefix: --sub-sample-increment

  exclude_singletons:
    type: boolean?
    default: false
    doc: Only count isoforms with > 1 supporting read
    inputBinding:
      prefix: --exclude-singletons

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
  saturation_txt:
    type: File
    doc: Saturation/subsampling report file
    outputBinding:
      glob: $(inputs.output_filename)

  log_file_output:
    type: File?
    outputBinding:
      glob: "${ return inputs.log_file ? inputs.log_file : []; }"
