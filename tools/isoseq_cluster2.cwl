cwlVersion: v1.2
class: CommandLineTool
label: Cluster FLNC reads and generate transcripts
requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  ShellCommandRequirement: {}
baseCommand: [isoseq, cluster2]

inputs:
  flnc_input:
    type: File
    doc: Input FLNC BAM, ConsensusReadSet XML, or FOFN
    inputBinding:
      position: 1
  transcripts_bam:
    type: string
    doc: Output transcripts BAM
    inputBinding:
      position: 2
  threads:
    type: int?
    default: 0
    doc: Number of threads to use, 0 means autodetection
    inputBinding:
      prefix: -j
  log_level:
    type: string?
    doc: Set log level (TRACE, DEBUG, INFO, WARN, FATAL)
    inputBinding:
      prefix: --log-level
  log_file:
    type: string?
    doc: Log to a file, instead of stderr
    inputBinding:
      prefix: --log-file
  singletons:
    type: boolean?
    doc: Output FLNCs that could not be clustered
    inputBinding:
      prefix: --singletons
  sort_threads:
    type: int?
    doc: Number of sorting threads per BAM file. Defaults to -j
    inputBinding:
      valueFrom: "$(inputs.sort_threads !== null ? inputs.sort_threads : inputs.threads)"
      prefix: --sort-threads
  write_bam:
    type: string?
    doc: Write annotated BAM file
    inputBinding:
      prefix: --write-bam

outputs:
  transcripts_output:
    type: File
    doc: Output transcripts BAM
    outputBinding:
      glob: $(inputs.transcripts_bam)
  transcripts_bam_pbi:
    type: File?
    doc: PacBio BAM index (.pbi) for transcripts_output
    outputBinding:
      glob: $(inputs.transcripts_bam).pbi
  singletons_output:
    type: File?
    doc: Optional singletons output if --singletons is used
    outputBinding:
      glob: "*.singletons.*"
  annotated_bam:
    type: File?
    doc: Optional annotated BAM if --write-bam is used
    outputBinding:
      glob: $(inputs.write_bam)
  report_csv:
    type: File?
    doc: CSV report file
    outputBinding:
      glob: "*.cluster_report.csv"
