cwlVersion: v1.2
class: CommandLineTool
label: Primer detection and demultiplex (lima --isoseq)
requirements:
  DockerRequirement:
    dockerImageId: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  ShellCommandRequirement: {}
baseCommand: [lima]
inputs:
  in_dataset:
    type: File
    doc: Input dataset (ConsensusReadSet XML or BAM)
    inputBinding:
      position: 1
  barcodes:
    type: File
    doc: Barcode/Primer FASTA (e.g., IsoSeq_v2_primers_12.fasta)
    inputBinding:
      position: 2
  out_prefix:
    type: string
    default: fl
    inputBinding:
      position: 3
      valueFrom: $( self + ".consensusreadset.xml" )
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
    type: string
    default: lima-isoseq.log
    inputBinding:
      prefix: --log-file
  isoseq_mode:
    type: boolean
    default: true
    inputBinding:
      prefix: --isoseq
  peek_guess:
    type: boolean
    default: true
    inputBinding:
      prefix: --peek-guess
  ignore_xml_biosamples:
    type: boolean
    default: true
    doc: Ignore <BioSamples> from XML input
    inputBinding:
      prefix: --ignore-xml-biosamples
  overwrite_biosample_names:
    type: boolean
    default: true
    doc: In isoseq mode, overwrite existing sample names in the SM tag
    inputBinding:
      prefix: --overwrite-biosample-names

outputs:
  out_dataset:
    type: File
    outputBinding:
      glob: $(inputs.out_prefix).consensusreadset.xml
  demux_bams:
    type: File[]?
    doc: Demultiplexed BAM files produced by lima (patterns like <out_prefix>*.bam)
    outputBinding:
      glob:
        - $(inputs.out_prefix)*.bam
  demux_bam_pbis:
    type: File[]?
    doc: PacBio BAM index files corresponding to demultiplexed BAMs (patterns like <out_prefix>*.bam.pbi)
    outputBinding:
      glob:
        - $(inputs.out_prefix)*.bam.pbi
  counts:
    type: File?
    outputBinding:
      glob:
        - $(inputs.out_prefix).lima.counts
  report:
    type: File?
    outputBinding:
      glob:
        - $(inputs.out_prefix).lima.report
  summary:
    type: File?
    outputBinding:
      glob:
        - $(inputs.out_prefix).lima.summary
  lima_log:
    type: File?
    doc: Log file from lima execution
    outputBinding:
      glob: $(inputs.log_file)