cwlVersion: v1.2
class: CommandLineTool
label: Iso-Seq collapse
requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  InlineJavascriptRequirement: {}
baseCommand: [isoseq, collapse]
inputs:
  alignments_bam:
    type: File
    doc: Alignments mapping Transcripts to reference genome
    inputBinding:
      position: 1
  flnc_bam:
    type: File
    doc: FLNC BAM, optional input
    inputBinding:
      position: 2
    secondaryFiles:
      - .pbi
  out_gff:
    type: string
    default: collapse_isoforms.gff
    doc: Collapsed transcripts GFF
    inputBinding:
      position: 3
  
  # Alignment Filter Options
  min_aln_coverage:
    type: float
    default: 0.99
    doc: Ignore alignments with less than minimum query read coverage
    inputBinding:
      prefix: --min-aln-coverage
  min_aln_identity:
    type: float
    default: 0.95
    doc: Ignore alignments with less than minimum alignment identity
    inputBinding:
      prefix: --min-aln-identity
  
  # Collapse Options
  max_fuzzy_junction:
    type: int
    default: 5
    doc: Ignore mismatches or indels shorter than or equal to N
    inputBinding:
      prefix: --max-fuzzy-junction
  max_5p_diff:
    type: int
    default: 50
    doc: Maximum allowed 5' difference if on same exon
    inputBinding:
      prefix: --max-5p-diff
  max_3p_diff:
    type: int
    default: 100
    doc: Maximum allowed 3' difference if on same exon
    inputBinding:
      prefix: --max-3p-diff
  do_not_collapse_extra_5exons:
    type: boolean
    default: true
    doc: Do not collapse 5' shorter transcripts which miss one or multiple 5' exons to a longer transcript
    inputBinding:
      prefix: --do-not-collapse-extra-5exons
  
  # General Options
  threads:
    type: int
    default: 0
    doc: Number of threads to use, 0 means autodetection
    inputBinding:
      prefix: -j
  log_level:
    type: string
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
  collapse_gff:
    type: File
    outputBinding:
      glob: $(inputs.out_gff)
  collapse_fasta:
    type: File?
    outputBinding:
      glob: $(inputs.out_gff.replace(/\.gff$/, '.fasta'))
  group_txt:
    type: File
    outputBinding:
      glob: $(inputs.out_gff.replace(/\.gff$/, '.group.txt'))
  flnc_count_txt:
    type: File
    outputBinding:
      glob: $(inputs.out_gff.replace(/\.gff$/, '.flnc_count.txt'))
  read_stat_txt:
    type: File
    outputBinding:
      glob: $(inputs.out_gff.replace(/\.gff$/, '.read_stat.txt'))
  collapse_report_json:
    type: File?
    outputBinding:
      glob: $(inputs.out_gff.replace(/\.gff$/, '.report.json'))
  abundance_txt:
    type: File?
    outputBinding:
      glob: $(inputs.out_gff.replace(/\.gff$/, '.abundance.txt'))
  log_file_output:
    type: File?
    outputBinding:
      glob: "${ return inputs.log_file ? inputs.log_file : []; }"
