cwlVersion: v1.2
class: Workflow

label: Scatter pigeon filter and report across multiple classified samples

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  # Inputs from classify scatter workflow
  classification_txts:
    type: File[]
    doc: Array of classification files
  junctions_txts:
    type: File[]
    doc: Array of junctions files
  isoforms_gffs:
    type:
      type: array
      items: ["null", File]
    doc: Array of sorted isoforms GFF files from classify step (may contain nulls)
  
  # Filter options
  polya_percent:
    type: float?
    default: 0.6
  polya_run_length:
    type: int?
    default: 6
  max_distance:
    type: int?
    default: 50
  min_cov:
    type: int?
    default: 3
  mono_exon:
    type: boolean?
    default: false
  skip_junctions:
    type: boolean?
    default: false
  filter_threads:
    type: int?
    default: 0
  
  # Report options
  sub_sample_increment:
    type: int?
    default: 0
  exclude_singletons:
    type: boolean?
    default: false
  report_threads:
    type: int?
    default: 0
  
  # General
  log_level:
    type: string?
    default: WARN

steps:
  filter_each:
    run: ../tools/pigeon_filter.cwl
    in:
      classification_txt: classification_txts
      junctions_txt: junctions_txts
      isoforms_gff: isoforms_gffs
      polya_percent: polya_percent
      polya_run_length: polya_run_length
      max_distance: max_distance
      min_cov: min_cov
      mono_exon: mono_exon
      skip_junctions: skip_junctions
      threads: filter_threads
      log_level: log_level
      log_file:
        valueFrom: |
          ${
            var basename = inputs.classification_txt.basename;
            var sample = basename.replace(/_classification\.txt$/, '');
            return "pigeon_filter_" + sample + ".log";
          }
    out: [filtered_classification_txt, filtered_junctions_txt, filtered_reasons_txt, filtered_gff, filtered_report_json, filtered_summary_txt]
    scatter: [classification_txt, junctions_txt, isoforms_gff]
    scatterMethod: dotproduct

  report_each:
    run: ../tools/pigeon_report.cwl
    in:
      classification_txt: filter_each/filtered_classification_txt
      output_filename:
        valueFrom: |
          ${
            var basename = inputs.classification_txt.basename;
            var sample = basename.replace(/\.txt$/, '');
            return sample + ".saturation.txt";
          }
      sub_sample_increment: sub_sample_increment
      exclude_singletons: exclude_singletons
      threads: report_threads
      log_level: log_level
      log_file:
        valueFrom: |
          ${
            var basename = inputs.classification_txt.basename;
            var sample = basename.replace(/\.txt$/, '');
            return "pigeon_report_" + sample + ".log";
          }
    out: [saturation_txt]
    scatter: [classification_txt]
    scatterMethod: dotproduct

outputs:
  # Filter outputs
  filtered_classification_txts:
    type: File[]
    outputSource: filter_each/filtered_classification_txt
  filtered_junctions_txts:
    type: File[]
    outputSource: filter_each/filtered_junctions_txt
  filtered_reasons_txts:
    type: File[]
    outputSource: filter_each/filtered_reasons_txt
  filtered_gffs:
    type:
      type: array
      items: [File, "null"]
    outputSource: filter_each/filtered_gff
  filtered_report_jsons:
    type: File[]
    outputSource: filter_each/filtered_report_json
  filtered_summary_txts:
    type: File[]
    outputSource: filter_each/filtered_summary_txt
  
  # Report outputs
  saturation_txts:
    type: File[]
    outputSource: report_each/saturation_txt
