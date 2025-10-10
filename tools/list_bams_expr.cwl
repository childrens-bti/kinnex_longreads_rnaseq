cwlVersion: v1.2
class: ExpressionTool
requirements:
  InlineJavascriptRequirement: {}
  LoadListingRequirement:
    loadListing: shallow_listing

inputs:
  demux_dir: Directory

outputs:
  bam_files:
    type: File[]
expression: |
  ${
    var entries = (inputs.demux_dir.listing || []);
    var list = entries.filter(function (e) {
      return e.class === 'File' && /\.bam$/i.test(e.basename) && !/\.pbi$/i.test(e.basename);
    });
    if (!list.length) {
      throw new Error('No BAM files found in ' + inputs.demux_dir.path);
    }
    list.sort(function(a,b){ return a.basename.localeCompare(b.basename); });
    return { bam_files: list };
  }