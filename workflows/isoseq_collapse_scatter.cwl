cwlVersion: v1.2
class: Workflow

label: Scatter isoseq collapse across multiple aligned BAMs

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  aligned_bam_dir: Directory
  flnc_bam_dir: Directory
  aligned_pattern:
    type: string?
    default: "^mapped\\..*\\.bam$"
    doc: >
      ECMAScript regex (as string) matched against aligned BAM basenames.
      Defaults to mapped BAMs from pbmm2 align.
  flnc_pattern:
    type: string?
    default: "^flnc\\..*\\.bam$"
    doc: >
      ECMAScript regex (as string) matched against FLNC BAM basenames.
  min_aln_coverage:
    type: float?
    default: 0.99
  min_aln_identity:
    type: float?
    default: 0.95
  max_fuzzy_junction:
    type: int?
    default: 5
  max_5p_diff:
    type: int?
    default: 50
  max_3p_diff:
    type: int?
    default: 100
  do_not_collapse_extra_5exons:
    type: boolean?
    default: true
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: WARN

steps:
  list_aligned_bams:
    run: ../tools/list_files_by_pattern.cwl
    in:
      dir: aligned_bam_dir
      pattern: aligned_pattern
    out: [files]

  list_flnc_bams:
    run: ../tools/list_files_by_pattern.cwl
    in:
      dir: flnc_bam_dir
      pattern: flnc_pattern
    out: [files]

  collapse_each:
    run: ../tools/isoseq_collapse.cwl
    in:
      alignments_bam: list_aligned_bams/files
      flnc_bam:
        source: list_flnc_bams/files
        valueFrom: |
          ${
            var f = self;
            var loc = f.location ? f.location : (f.path ? "file://" + f.path : null);
            var out = { class: 'File' };
            if (loc) out.location = loc;
            if (f.basename) out.basename = f.basename;
            if (f.nameroot) out.nameroot = f.nameroot;
            if (f.nameext) out.nameext = f.nameext;
            out.secondaryFiles = [{ class: 'File', location: (loc || '') + '.pbi' }];
            return out;
          }
      out_gff:
        valueFrom: $("collapse_isoforms." + inputs.alignments_bam.basename.replace(/\.transcripts\.bam$/, '').replace(/^mapped\.clustered\./, '') + ".gff")
      min_aln_coverage: min_aln_coverage
      min_aln_identity: min_aln_identity
      max_fuzzy_junction: max_fuzzy_junction
      max_5p_diff: max_5p_diff
      max_3p_diff: max_3p_diff
      do_not_collapse_extra_5exons: do_not_collapse_extra_5exons
      threads: threads
      log_level: log_level
      log_file:
        valueFrom: $("collapse_isoforms." + inputs.alignments_bam.basename.replace(/\.transcripts\.bam$/, '').replace(/^mapped\.clustered\./, '') + ".log")
    out: [collapse_gff, collapse_fasta, group_txt, flnc_count_txt, read_stat_txt, collapse_report_json, abundance_txt]
    scatter: [alignments_bam, flnc_bam]
    scatterMethod: dotproduct

outputs:
  collapse_gffs:
    type: File[]
    outputSource: collapse_each/collapse_gff
  collapse_fastas:
    type: File[]?
    outputSource: collapse_each/collapse_fasta
  group_txts:
    type: File[]
    outputSource: collapse_each/group_txt
  flnc_count_txts:
    type: File[]
    outputSource: collapse_each/flnc_count_txt
  read_stat_txts:
    type: File[]
    outputSource: collapse_each/read_stat_txt
  collapse_report_jsons:
    type: File[]?
    outputSource: collapse_each/collapse_report_json
  abundance_txts:
    type: File[]?
    outputSource: collapse_each/abundance_txt
