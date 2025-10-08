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

steps:
  skera_split:
    run: tools/skera_split.cwl
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
      out_prefix: out_prefix
    out: [segmented_bam, non_passing_bam, report_json]

outputs:
  segmented_bam:
    type: File
    outputSource: skera_split/segmented_bam
  non_passing_bam:
    type: File?
    outputSource: skera_split/non_passing_bam
  report_json:
    type: File?
    outputSource: skera_split/report_json
