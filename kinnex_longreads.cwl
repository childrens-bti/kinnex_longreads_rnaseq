cwlVersion: v1.2
class: Workflow
label: Kinnex/MAS-Iso-Seq Complete Long-Read Pipeline

doc: |
  Complete end-to-end pipeline for PacBio Kinnex/MAS-Iso-Seq long-read transcriptome analysis.
  
  Pipeline Steps:
  1. Skera: Segment HiFi reads into individual transcripts
  2. Lima: Demultiplex segmented reads by barcodes
  3. IsoSeq Refine: Trim and filter full-length non-concatemer (FLNC) reads
  4. IsoSeq Cluster2: Cluster FLNC reads into transcript models
  5. PBMM2: Align transcript models to reference genome
  6. IsoSeq Collapse: Collapse aligned reads into unique isoforms
  7. Pigeon Classify: Classify isoforms based on reference annotation
  8. Pigeon Filter & Report: Filter classified isoforms and generate saturation reports

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  # Primary inputs
  hifi_bam:
    type: File
    doc: HiFi BAM file containing reads to segment
    secondaryFiles:
      - required: false
        pattern: .pbi
  
  adapters_fa:
    type: File
    doc: Adapters FASTA file (e.g., mas8_primers.fasta)
    sbg:suggestedValue:
      class: File
      path: 69136bfa3ae0fb7894e8f432
      name: mas8_primers.fasta
  
  reference_fa:
    type: File
    doc: Reference genome FASTA file
    sbg:suggestedValue:
      class: File
      path: 69136c872c7f921b1de307c3
      name: GRCh38.primary_assembly.genome.fa
  
  annotation_gtf:
    type: File
    doc: Reference annotation GTF file
    sbg:suggestedValue:
      class: File
      path: 69136c872c7f921b1de307c2
      name: gencode.v39.primary_assembly.annotation.gtf
  
  # Skera options
  skera_out_prefix:
    type: string?
    default: segmented
  skera_threads:
    type: int?
    default: 0
  skera_use_dataset_xml:
    type: boolean?
    default: true
  
  # Lima options
  lima_out_prefix:
    type: string?
    default: fl
  lima_barcodes:
    type: File
    doc: Barcode/Primer FASTA for lima demultiplexing
    sbg:suggestedValue:
      class: File
      path: 69136bf977b8bd08be280d35
      name: IsoSeq_v2_primers_12.fasta
  lima_threads:
    type: int?
    default: 0
  
  # Refine options
  refine_threads:
    type: int?
    default: 0
  refine_require_polya:
    type: boolean?
    default: true
  
  # Cluster options
  cluster_threads:
    type: int?
    default: 0
  cluster_singletons:
    type: boolean?
    default: false
  
  # PBMM2 options
  pbmm2_threads:
    type: int?
    default: 0
  pbmm2_preset:
    type: string?
    default: ISOSEQ
  pbmm2_sort:
    type: boolean?
    default: true
  pbmm2_min_gap_comp_id_perc:
    type: float?
    default: 95.0
  pbmm2_bam_index:
    type: string?
    doc: BAM index type for sorted output (NONE, BAI, CSI). If not specified, uses pbmm2 default.
  
  # Collapse options
  collapse_min_aln_coverage:
    type: float?
    default: 0.99
  collapse_min_aln_identity:
    type: float?
    default: 0.95
  collapse_max_fuzzy_junction:
    type: int?
    default: 5
  collapse_max_5p_diff:
    type: int?
    default: 50
  collapse_max_3p_diff:
    type: int?
    default: 100
  collapse_do_not_collapse_extra_5exons:
    type: boolean?
    default: true
  collapse_threads:
    type: int?
    default: 0
  
  # Classify options
  classify_threads:
    type: int?
    default: 0
  classify_out_prefix_base:
    type: string?
    default: "pigeon"
    doc: Base prefix for pigeon classify output files
  
  # Filter options
  filter_polya_percent:
    type: float?
    default: 0.6
  filter_polya_run_length:
    type: int?
    default: 6
  filter_max_distance:
    type: int?
    default: 50
  filter_min_cov:
    type: int?
    default: 3
  filter_mono_exon:
    type: boolean?
    default: false
  filter_skip_junctions:
    type: boolean?
    default: false
  filter_threads:
    type: int?
    default: 0
  
  # Report options
  report_sub_sample_increment:
    type: int?
    default: 0
  report_exclude_singletons:
    type: boolean?
    default: false
  report_threads:
    type: int?
    default: 0
  
  # General options
  log_level:
    type: string?
    default: INFO

steps:
  # Step 1: Segment HiFi reads
  skera:
    run: workflows/skera.cwl
    in:
      hifi_bam: hifi_bam
      adapters_fa: adapters_fa
      out_prefix: skera_out_prefix
      threads: skera_threads
      use_dataset_xml: skera_use_dataset_xml
      log_level: log_level
    out: [segmented_bam, non_passing_bam, segmented_dataset, summary_csv, ligations_csv, read_lengths_csv, adapters_csv_gz]

  # Step 2: Demultiplex by barcodes
  lima:
    run: workflows/lima_isoseq_run.cwl
    in:
      in_dataset: skera/segmented_bam
      barcodes: lima_barcodes
      out_prefix: lima_out_prefix
      threads: lima_threads
      log_level: log_level
    out: [out_dataset, demux_bams, counts, report, summary, lima_log]

  # Step 3: Refine FLNC reads (scatter across barcodes)
  refine:
    run: workflows/isoseq_refine_scatter.cwl
    in:
      demux_bams:
        source: lima/demux_bams
        valueFrom: $(self)
      barcodes: lima_barcodes
      threads: refine_threads
      log_level: log_level
      require_polya: refine_require_polya
    out: [out_flnc_bams, filter_summaries, reports]

  # Step 4: Cluster FLNC reads into transcripts (scatter across samples)
  cluster:
    run: workflows/isoseq_cluster2_scatter.cwl
    in:
      flnc_bams:
        source: refine/out_flnc_bams
        valueFrom: $(self)
      threads: cluster_threads
      log_level: log_level
      singletons: cluster_singletons

    out: [transcripts_bams, singletons_outputs, annotated_bams, report_csvs]

  # Step 5: Align transcripts to reference (scatter across samples)
  pbmm2:
    run: workflows/pbmm2_align_scatter.cwl
    in:
      reference: reference_fa
      transcript_bams:
        source: cluster/transcripts_bams
        valueFrom: $(self)
      preset: pbmm2_preset
      threads: pbmm2_threads
      sort: pbmm2_sort
      bam_index: pbmm2_bam_index
      min_gap_comp_id_perc: pbmm2_min_gap_comp_id_perc
      log_level: log_level
    out: [mapped_bams, log_files]

  # Step 6: Collapse aligned reads into isoforms (scatter across samples)
  collapse:
    run: workflows/isoseq_collapse_scatter.cwl
    in:
      aligned_bams:
        source: pbmm2/mapped_bams
        valueFrom: $(self)
      flnc_bams:
        source: refine/out_flnc_bams
        valueFrom: $(self)
      min_aln_coverage: collapse_min_aln_coverage
      min_aln_identity: collapse_min_aln_identity
      max_fuzzy_junction: collapse_max_fuzzy_junction
      max_5p_diff: collapse_max_5p_diff
      max_3p_diff: collapse_max_3p_diff
      do_not_collapse_extra_5exons: collapse_do_not_collapse_extra_5exons
      threads: collapse_threads
      log_level: log_level
    out: [collapse_gffs, collapse_fastas, group_txts, flnc_count_txts, read_stat_txts, collapse_report_jsons, abundance_txts]

  # Step 7: Classify isoforms (scatter across samples)
  classify:
    run: workflows/pigeon_classify_scatter.cwl
    in:
      collapse_gffs: collapse/collapse_gffs
      annotation_gtf: annotation_gtf
      reference_fa: reference_fa
      flnc_counts: collapse/flnc_count_txts
      out_prefix_base: classify_out_prefix_base
      threads: classify_threads
      log_level: log_level
    out: [classification_txts, junctions_txts, report_jsons, summary_txts, prepared_isoforms_gffs]

  # Step 8: Filter and report (scatter across samples)
  filter_report:
    run: workflows/pigeon_filter_report_scatter.cwl
    in:
      classification_txts: classify/classification_txts
      junctions_txts: classify/junctions_txts
      isoforms_gffs: classify/prepared_isoforms_gffs
      polya_percent: filter_polya_percent
      polya_run_length: filter_polya_run_length
      max_distance: filter_max_distance
      min_cov: filter_min_cov
      mono_exon: filter_mono_exon
      skip_junctions: filter_skip_junctions
      filter_threads: filter_threads
      sub_sample_increment: report_sub_sample_increment
      exclude_singletons: report_exclude_singletons
      report_threads: report_threads
      log_level: log_level
    out: [filtered_classification_txts, filtered_junctions_txts, filtered_reasons_txts, filtered_gffs, filtered_report_jsons, filtered_summary_txts, saturation_txts]

outputs:
  # Skera outputs
  segmented_bam:
    type: File
    outputSource: skera/segmented_bam
  segmented_summary:
    type: File?
    outputSource: skera/summary_csv
  non_passing_bam:
    type: File
    outputSource: skera/non_passing_bam
  segmented_dataset:
    type: File?
    outputSource: skera/segmented_dataset
  ligations_csv:
    type: File?
    outputSource: skera/ligations_csv
  read_lengths_csv:
    type: File?
    outputSource: skera/read_lengths_csv
  adapters_csv_gz:
    type: File?
    outputSource: skera/adapters_csv_gz
  
  # Lima outputs
  lima_out_dataset:
    type: File
    outputSource: lima/out_dataset
  demux_bams:
    type: File[]
    outputSource: lima/demux_bams
  lima_counts:
    type: File?
    outputSource: lima/counts
  lima_report:
    type: File?
    outputSource: lima/report
  lima_summary:
    type: File?
    outputSource: lima/summary
  lima_log:
    type: File?
    outputSource: lima/lima_log
  
  # Refine outputs
  flnc_bams:
    type: File[]
    outputSource: refine/out_flnc_bams
  refine_filter_summaries:
    type: File[]?
    outputSource: refine/filter_summaries
  refine_reports:
    type: File[]?
    outputSource: refine/reports
  
  # Cluster outputs
  transcripts_bams:
    type: File[]
    outputSource: cluster/transcripts_bams
  cluster_singletons_outputs:
    type: File[]?
    outputSource: cluster/singletons_outputs
  cluster_annotated_bams:
    type: File[]?
    outputSource: cluster/annotated_bams
  cluster_reports:
    type: File[]?
    outputSource: cluster/report_csvs
  
  # PBMM2 outputs
  mapped_bams:
    type: File[]
    outputSource: pbmm2/mapped_bams
  pbmm2_log_files:
    type: File[]?
    outputSource: pbmm2/log_files
  
  # Collapse outputs
  collapse_gffs:
    type: File[]
    outputSource: collapse/collapse_gffs
  collapse_fastas:
    type: File[]?
    outputSource: collapse/collapse_fastas
  collapse_group_txts:
    type: File[]
    outputSource: collapse/group_txts
  flnc_count_txts:
    type: File[]
    outputSource: collapse/flnc_count_txts
  collapse_read_stat_txts:
    type: File[]
    outputSource: collapse/read_stat_txts
  collapse_reports:
    type: File[]?
    outputSource: collapse/collapse_report_jsons
  collapse_abundance_txts:
    type: File[]?
    outputSource: collapse/abundance_txts
  
  # Classify outputs
  classification_txts:
    type: File[]
    outputSource: classify/classification_txts
  junctions_txts:
    type: File[]
    outputSource: classify/junctions_txts
  classify_reports:
    type: File[]
    outputSource: classify/report_jsons
  classify_summaries:
    type: File[]
    outputSource: classify/summary_txts
  prepared_isoforms_gffs:
    type:
      type: array
      items: ["null", File]
    outputSource: classify/prepared_isoforms_gffs
  
  # Filter & Report outputs (final recommended outputs)
  filtered_classification_txts:
    type: File[]
    outputSource: filter_report/filtered_classification_txts
    doc: Quality-filtered transcript classifications
  
  filtered_junctions_txts:
    type: File[]
    outputSource: filter_report/filtered_junctions_txts
    doc: Quality-filtered junction information
  
  filtered_reasons_txts:
    type: File[]
    outputSource: filter_report/filtered_reasons_txts
    doc: Filtering reason codes
  
  filtered_gffs:
    type:
      type: array
      items: [File, "null"]
    outputSource: filter_report/filtered_gffs
    doc: Quality-filtered isoform annotations (recommended for downstream analysis)
  
  filtered_reports:
    type: File[]
    outputSource: filter_report/filtered_report_jsons
    doc: Comprehensive filtering statistics
  
  filtered_summaries:
    type: File[]
    outputSource: filter_report/filtered_summary_txts
    doc: Summary filtering metrics
  
  saturation_reports:
    type: File[]
    outputSource: filter_report/saturation_txts
    doc: Transcript discovery saturation analysis

$namespaces:
  sbg: "https://sevenbridges.com/"
hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
"sbg:links":
- id: "https://github.com/childrens-bti/kinnex_longreads/tree/feat/workflow_sketch" # will update with stable release
  label: github-release