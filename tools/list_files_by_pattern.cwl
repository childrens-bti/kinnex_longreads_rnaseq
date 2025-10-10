cwlVersion: v1.2
class: ExpressionTool
label: List files by regex pattern (basename match)

requirements:
  InlineJavascriptRequirement: {}
  LoadListingRequirement:
    loadListing: shallow_listing

inputs:
  dir:
    type: Directory
  pattern:
    type: string
    doc: >
      ECMAScript/JS regular expression as a string, matched against the
      file basename. Example: "^fl\\..*\\.bam$"

outputs:
  files: File[]

expression: |-
  ${
  var rx = new RegExp(inputs.pattern); // case-sensitive by default
  var entries = (inputs.dir.listing || []).filter(function (e) {
    return e.class === 'File' && rx.test(e.basename);
  });
  if (!entries.length) {
    throw new Error('No files matched pattern "' + inputs.pattern + '" in ' +
            (inputs.dir.path || inputs.dir.basename));
  }
  entries.sort(function (a, b) { return a.basename.localeCompare(b.basename); });
  return { files: entries };
  }
