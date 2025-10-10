cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  LoadListingRequirement:
    loadListing: shallow_listing

inputs:
  hifi_dir: Directory
  out_prefix:
    type: string
    default: segmented
  primers_fa:
    type: File
    doc: Adapters FASTA (e.g., params/mas8_primers.fasta)
  threads:
    type: int
    default: 0
  use_dataset_xml:
    type: boolean
    default: true
  log_level:
    type: string?
  log_file:
    type: string?

steps:
  skera_split:
    run: ../tools/skera_split.cwl
    in:
      # find the hifi BAM file from hifi_dir
      in_bam:
        source: hifi_dir
        valueFrom: >
          ${
            // ES5.1 only
            var entries = (self.listing || []);
            // keep only files that look like *bc*.bam but not *.unassigned.bam
            var list = entries.filter(function (e) {
              return e.class === 'File' &&
                     /bc.*\.bam$/i.test(e.basename) &&
                     !/\.unassigned\.bam$/i.test(e.basename);
            });
            if (!list.length) {
              throw new Error('No matching BAMs in ' + self.path);
            }
            // deterministic: sort by basename
            list.sort(function (a, b) {
              return a.basename.localeCompare(b.basename);
            });
            // return the File object itself (no copy here)
            return list[0];
          }
      primers_fa: primers_fa
      out_prefix: out_prefix
      threads: threads
      use_dataset_xml: use_dataset_xml
      log_level: log_level
      log_file: log_file
    out: [segmented_bam, segmented_bam_pbi, non_passing_bam, non_passing_bam_pbi, segmented_dataset, summary_csv, ligations_csv, read_lengths_csv, adapters_csv_gz]

outputs:
  segmented_bam:
    type: File
    outputSource: skera_split/segmented_bam
  segmented_bam_pbi:
    type: File?
    outputSource: skera_split/segmented_bam_pbi
  non_passing_bam:
    type: File
    outputSource: skera_split/non_passing_bam
  non_passing_bam_pbi:
    type: File?
    outputSource: skera_split/non_passing_bam_pbi
  segmented_dataset:
    type: File
    outputSource: skera_split/segmented_dataset
  summary_csv:
    type: File?
    outputSource: skera_split/summary_csv
  ligations_csv:
    type: File?
    outputSource: skera_split/ligations_csv
  read_lengths_csv:
    type: File?
    outputSource: skera_split/read_lengths_csv
  adapters_csv_gz:
    type: File?
    outputSource: skera_split/adapters_csv_gz
