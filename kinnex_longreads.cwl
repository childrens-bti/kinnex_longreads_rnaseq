cwlVersion: v1.2
class: Workflow
label: Kinnex/MAS-Iso-Seq Complete Long-Read Pipeline

doc: |
  Complete end-to-end pipeline for PacBio Kinnex/MAS-Iso-Seq long-read transcriptome analysis
  with multi-SMRTcell support for resource-efficient processing.
  
  This workflow processes PacBio HiFi reads through a comprehensive isoform discovery and 
  characterization pipeline, integrating bioassay ID tracking for sample provenance.
  
  Multi-SMRTcell Strategy (Resource-Efficient):
  When processing the same Kinnex library run on multiple SMRTcells:
  1. Process each SMRTcell independently through Skera & Lima (avoids merging huge files)
  2. Merge only the small per-barcode demultiplexed BAMs from each SMRTcell
  3. Continue downstream with merged per-sample BAMs
  
  This approach uses ~10x less disk space than upfront merging for 70GB+ BAMs.
  
  Pipeline Steps:
  0. Parse Manifest: Extract barcode-to-Bioassay_ID mappings from TSV manifest (required)
  1. Skera: Segment HiFi reads containing multiple transcripts into individual molecules
  2. Lima: Demultiplex segmented reads by barcodes and apply Bioassay ID prefixes
  2b. Merge Demultiplexed: Merge per-barcode BAMs across SMRTcells (small files)
  3. IsoSeq Refine: Trim polyA tails and filter full-length non-concatemer (FLNC) reads
  4. IsoSeq Cluster2: Cluster FLNC reads into consensus transcript models
  5. Align transcript models to the reference genome with the selected aligner
  6. IsoSeq Collapse: Collapse redundant isoforms into unique transcript representations
  7. Pigeon Prepare & Classify: Classify isoforms against reference annotation
  8. Pigeon Filter & Report: Apply quality filters and generate saturation analysis
  
  Key Features:
  - Bioassay ID Integration: All outputs are prefixed with stable sample identifiers (BA_XXXXX)
    for traceability and downstream data integration
  - Barcode Preservation: Original barcode names are maintained in filenames alongside BA_IDs
  - Multi-SMRTcell Efficiency: Processes separate BAMs independently, merges only demultiplexed files
  - Scatter Parallelization: Steps 3-8 process samples in parallel for efficiency
  - Comprehensive QC: Generates reports at each step for quality assessment
  
  Input Requirements:
  - CAVATICA Naming: Set output_basename as <project_id>_<task_id> (e.g., SR009023_task001).
    Per-SMRTcell prefix: output_basename.hifi_bam_basename
  - HiFi BAMs: Array of PacBio HiFi sequencing reads (one per SMRTcell)
  - Sample Manifest: TSV file mapping lima output filenames to Bioassay_IDs
    Required columns: file_name, Bioassay_ID
    Example: fl.IsoSeqX_bc01_5p--IsoSeqX_3p.bam -> BA_9B3T9910
  - Reference Files: Genome FASTA, annotation GTF, adapter sequences, barcode primers
  
  Output Naming Convention:
  All outputs follow the pattern: BA_<ID>.<step>.<barcode>.<suffix>
  Example progression:
  - Lima:     BA_9B3T9910.fl.IsoSeqX_bc01_5p--IsoSeqX_3p.bam (from SMRTcell1)
  - Merged:   BA_9B3T9910.fl.IsoSeqX_bc01_5p--IsoSeqX_3p.merged.bam (SMRTcell1+2)
  - Refine:   BA_9B3T9910.flnc.IsoSeqX_bc01_5p--IsoSeqX_3p.bam
  - Cluster:  BA_9B3T9910.clustered.IsoSeqX_bc01_5p--IsoSeqX_3p.transcripts.bam
  - Align:    BA_9B3T9910.mapped.IsoSeqX_bc01_5p--IsoSeqX_3p.bam
  - Collapse: BA_9B3T9910.collapse_isoforms.IsoSeqX_bc01_5p--IsoSeqX_3p.gff
  - Classify: BA_9B3T9910.pigeon.IsoSeqX_bc01_5p--IsoSeqX_3p_classification.txt
  
  For detailed parameter descriptions and tuning recommendations, see individual tool documentation.

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  # Primary inputs
  output_basename:
    type: string
    doc: |
      Run-level output prefix for all generated files.
      On CAVATICA, set this as <project_id>_<task_id> (e.g., SR009023_task001),
      where project_id is the PacBio project ID and task_id is the CAVATICA task ID.
      Per-SMRTcell outputs are further prefixed as: output_basename.<hifi_bam_basename>
  
  hifi_bams:
    type: File[]
    doc: |
      Array of HiFi BAM files to process. Provide one per SMRTcell.
      
      For single SMRTcell: [single.bam]
      For multiple SMRTcells (resource-efficient merging after demultiplexing):
        [smrt_cell1.bam, smrt_cell2.bam]
      
      When multiple BAMs provided:
      - Each is processed independently through Skera & Lima
      - Per-barcode outputs are then merged by barcode name
      - This avoids merging huge undemultiplexed files
      - Number of SMRTcells is auto-detected from this array length

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
  
  sample_manifest:
    type: File
    doc: TSV manifest with file_name and Bioassay_ID columns for sample ID mapping (required)


  # Skera options
  skera_threads:
    type: int?
    default: 24
  skera_use_dataset_xml:
    type: boolean?
    default: true
  
  # Lima options
  lima_barcodes:
    type: File
    doc: Barcode/Primer FASTA for lima demultiplexing
    sbg:suggestedValue:
      class: File
      path: 69136bf977b8bd08be280d35
      name: IsoSeq_v2_primers_12.fasta
  lima_threads:
    type: int?
    default: 36
  lima_ram_gb:
    type: int?
    default: 32
  
  # Refine options
  refine_threads:
    type: int?
    default: 24

  # Merge BAMs options
  merge_bams_threads:
    type: int?
    default: 24
  merge_bams_ram_gb:
    type: int?
    default: 48
  refine_require_polya:
    type: boolean?
    default: true
  
  # Cluster options
  cluster_threads:
    type: int?
    default: 32
  cluster_ram_gb:
    type: int?
    default: 48
  cluster_singletons:
    type: boolean?
    default: false
  cluster_write_bam:
    type: boolean?
    default: false
    doc: Write annotated BAM file from cluster2
  
  # PBMM2 options
  alignment_method:
    type:
      type: enum
      symbols: [pbmm2, minimap2, ultra]
    default: minimap2
    doc: "Alignment method. Supported values: pbmm2, minimap2, or ultra. minimap2 uses GTF-derived junctions; ultra uses a GTF-derived uLTRA index."
  pbmm2_threads:
    type: int?
    default: 36
  pbmm2_preset:
    type: string?
    default: ISOSEQ
  pbmm2_seed_k:
    type: int?
    default: 15
    doc: Minimizer k-mer size for pbmm2. Matches the ISOSEQ preset default.
  pbmm2_seed_w:
    type: int?
    default: 5
    doc: Minimizer window size for pbmm2.
  pbmm2_sort:
    type: boolean?
    default: true
  pbmm2_min_gap_comp_id_perc:
    type: float?
    default: 95.0
  pbmm2_bam_index:
    type: string?
    doc: BAM index type for sorted output (NONE, BAI, CSI). If not specified, uses pbmm2 default.

  # minimap2 options
  minimap2_threads:
    type: int?
    default: 36
  minimap2_sort_threads:
    type: int?
    default: 4
  minimap2_seed_k:
    type: int?
    default: 15
  minimap2_seed_w:
    type: int?
    default: 5

  # uLTRA options
  ultra_threads:
    type: int?
    default: 36
  ultra_sort_threads:
    type: int?
    default: 4
  ultra_index_thinning:
    type: int?
    doc: uLTRA index seed thinning level (0-2); omit for uLTRA default.

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
    default: 24
  
  # Classify options
  classify_threads:
    type: int?
    default: 24
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
    default: 24
  
  # Report options
  report_sub_sample_increment:
    type: int?
    default: 0
  report_exclude_singletons:
    type: boolean?
    default: false
  report_threads:
    type: int?
    default: 12
  
  # General options
  log_level:
    type: string?
    default: INFO

steps:
  # Step 0: Parse manifest to create barcode-to-Bioassay_ID mapping
  parse_manifest:
    run: tools/parse_manifest.cwl
    in:
      manifest: sample_manifest
    out: [barcode_mapping]

  # Step 1-2: Process each SMRTcell independently (Skera + Lima scatter)
  skera_lima_scatter:
    run: workflows/skera_lima_per_smrtcell.cwl
    in:
      hifi_bam: hifi_bams
      adapters_fa: adapters_fa
      lima_barcodes: lima_barcodes
      out_prefix:
        source: output_basename
        valueFrom: |
          ${
            var bam_name = inputs.hifi_bam.nameroot;
            return self + '.' + bam_name;
          }
      skera_threads: skera_threads
      skera_use_dataset_xml: skera_use_dataset_xml
      lima_threads: lima_threads
      log_level: log_level
      lima_ram_gb: lima_ram_gb
    scatter: hifi_bam
    scatterMethod: dotproduct
    requirements:
      - class: ResourceRequirement
        ramMin: $(inputs.lima_ram_gb * 1024)
    out: [segmented_bam, demux_bams, lima_counts, lima_report, lima_summary]

  # Step 2b: Merge demultiplexed BAMs by barcode across SMRTcells
  merge_demux_bams:
    run: tools/merge_demux_bams_by_barcode.cwl
    in:
      demux_bams:
        source: skera_lima_scatter/demux_bams
        valueFrom: |
          ${
            var flat = [];
            for (var i = 0; i < self.length; i++) {
              if (self[i]) {
                for (var j = 0; j < self[i].length; j++) {
                  flat.push(self[i][j]);
                }
              }
            }
            return flat;
          }
      output_basename: output_basename
      num_smrt_cells:
        source: hifi_bams
        valueFrom: $(self.length)
      threads: merge_bams_threads
      merge_bams_ram_gb: merge_bams_ram_gb
    requirements:
      - class: ResourceRequirement
        ramMin: $(inputs.merge_bams_ram_gb * 1024)
    out: [merged_bams]

  # Step 2c: Rename merged BAMs with Bioassay IDs
  rename_demux_bams:
    run: tools/rename_bams_with_bioassay_id.cwl
    in:
      input_bams: merge_demux_bams/merged_bams
      barcode_mapping: parse_manifest/barcode_mapping
    out: [renamed_bams]

  # Step 3: Refine FLNC reads (scatter across merged barcodes)
  refine:
    run: workflows/isoseq_refine_scatter.cwl
    in:
      demux_bams:
        source: rename_demux_bams/renamed_bams
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
      write_bam: cluster_write_bam
      cluster_ram_gb: cluster_ram_gb
    requirements:
      - class: ResourceRequirement
        ramMin: $(inputs.cluster_ram_gb * 1024)
    out: [transcripts_bams, singletons_outputs, annotated_bams, report_csvs]

  # Step 5: Align transcripts to reference with one selected aligner
  align:
    run: workflows/alignment_router.cwl
    in:
      reference: reference_fa
      annotation_gtf: annotation_gtf
      transcript_bams:
        source: cluster/transcripts_bams
        valueFrom: $(self)
      alignment_method: alignment_method
      pbmm2_preset: pbmm2_preset
      pbmm2_seed_k: pbmm2_seed_k
      pbmm2_seed_w: pbmm2_seed_w
      pbmm2_threads: pbmm2_threads
      pbmm2_sort: pbmm2_sort
      pbmm2_bam_index: pbmm2_bam_index
      pbmm2_min_gap_comp_id_perc: pbmm2_min_gap_comp_id_perc
      log_level: log_level
      minimap2_seed_k: minimap2_seed_k
      minimap2_seed_w: minimap2_seed_w
      minimap2_threads: minimap2_threads
      minimap2_sort_threads: minimap2_sort_threads
      ultra_threads: ultra_threads
      ultra_sort_threads: ultra_sort_threads
      ultra_index_thinning: ultra_index_thinning
    out: [mapped_bams, bam_indices, log_files]

  # Step 6: Collapse aligned reads into isoforms (scatter across samples)
  collapse:
    run: workflows/isoseq_collapse_scatter.cwl
    in:
      aligned_bams:
        source: align/mapped_bams
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
  # Skera outputs (from scatter)
  segmented_bams:
    type: File[]
    outputSource: skera_lima_scatter/segmented_bam
    doc: Segmented BAMs from each SMRTcell
  
  # Lima outputs (from scatter, before merging)
  demux_bams_per_cell:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: skera_lima_scatter/demux_bams
    doc: Per-barcode demultiplexed BAMs from each SMRTcell
  
  lima_counts:
    type:
      type: array
      items: ["null", File]
    outputSource: skera_lima_scatter/lima_counts
    doc: Lima demultiplexing count reports from each SMRTcell
  
  lima_report:
    type:
      type: array
      items: ["null", File]
    outputSource: skera_lima_scatter/lima_report
    doc: Lima demultiplexing reports from each SMRTcell
  
  lima_summary:
    type:
      type: array
      items: ["null", File]
    outputSource: skera_lima_scatter/lima_summary
    doc: Lima demultiplexing summaries from each SMRTcell
  
  # Merged demultiplexed BAMs (one per barcode)
  merged_demux_bams:
    type: File[]
    outputSource: rename_demux_bams/renamed_bams
    doc: Demultiplexed BAMs merged by barcode across all SMRTcells, renamed with Bioassay IDs
  
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
  
  # Alignment outputs
  mapped_bams:
    type: File[]
    outputSource: align/mapped_bams
  alignment_log_files:
    type: File[]?
    outputSource: align/log_files
  mapped_bam_indices:
    type: File[]?
    outputSource: align/bam_indices
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
  value: 4
"sbg:links":
- id: "https://github.com/childrens-bti/kinnex_longreads/releases/tag/v1.1.0"
  label: github-release
