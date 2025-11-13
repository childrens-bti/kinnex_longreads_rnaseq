cwlVersion: v1.2
class: Workflow

label: Scatter pigeon prepare+classify across multiple collapsed GFF files

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  collapse_gffs:
    type: File[]
    doc: Array of collapse GFF files
  annotation_gtf:
    type: File
    doc: Reference annotation GTF file (will be prepared by pigeon prepare)
  reference_fa:
    type: File
    doc: Reference FASTA file (will be prepared by pigeon prepare)
  flnc_counts:
    type: File[]
    doc: Array of FLNC count files (*.flnc_count.txt) from isoseq collapse
  out_prefix_base:
    type: string?
    default: "pigeon"
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: WARN

steps:
  prepare_references:
    run: ../tools/pigeon_prepare.cwl
    in:
      input_files:
        source: [annotation_gtf, reference_fa]
        linkMerge: merge_flattened
      log_level: log_level
    out: [prepared_annotation, prepared_reference]

  prepare_isoforms:
    run: ../tools/pigeon_prepare.cwl
    in:
      input_files:
        source: collapse_gffs
        valueFrom: $([self])
      log_level: log_level
    out: [prepared_isoforms]
    scatter: [input_files]
    scatterMethod: dotproduct

  classify_each:
    run: ../tools/pigeon_classify.cwl
    in:
      annotation_gtf: prepare_references/prepared_annotation
      reference_fa: prepare_references/prepared_reference
      isoforms_gff: prepare_isoforms/prepared_isoforms
      flnc_count: flnc_counts
      out_prefix_base: out_prefix_base
      out_prefix:
        valueFrom: |
          ${
            var prefix_base = inputs.out_prefix_base || "pigeon";
            var basename = inputs.isoforms_gff.basename;
            var sample = basename.replace(/^collapse_isoforms\./, '').replace(/\.sorted\.gff$/, '').replace(/\.gff$/, '');
            return prefix_base + "." + sample;
          }
      threads: threads
      log_level: log_level
      log_file:
        valueFrom: |
          ${
            var prefix_base = inputs.out_prefix_base || "pigeon";
            var basename = inputs.isoforms_gff.basename;
            var sample = basename.replace(/^collapse_isoforms\./, '').replace(/\.sorted\.gff$/, '').replace(/\.gff$/, '');
            return prefix_base + "_classify_" + sample + ".log";
          }
    out: [classification_txt, junctions_txt, report_json, summary_txt]
    scatter: [isoforms_gff, flnc_count]
    scatterMethod: dotproduct

outputs:
  classification_txts:
    type: File[]
    outputSource: classify_each/classification_txt
  junctions_txts:
    type: File[]
    outputSource: classify_each/junctions_txt
  report_jsons:
    type: File[]
    outputSource: classify_each/report_json
  summary_txts:
    type: File[]
    outputSource: classify_each/summary_txt
  prepared_isoforms_gffs:
    type:
      type: array
      items: ["null", File]
    outputSource: prepare_isoforms/prepared_isoforms
    doc: Sorted isoforms GFF files from prepare step (to be used by filter workflow)
