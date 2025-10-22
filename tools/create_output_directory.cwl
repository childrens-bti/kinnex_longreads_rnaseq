cwlVersion: v1.2
class: ExpressionTool

doc: |
  Helper tool to create a Directory object from an array of files.
  This is useful for passing outputs from one scatter step as a Directory input to the next step.

requirements:
  InlineJavascriptRequirement: {}

inputs:
  files:
    type: File[]
    doc: Array of files to include in the directory
  dir_name:
    type: string
    default: output_dir
    doc: Name for the output directory

outputs:
  output_dir:
    type: Directory

expression: |
  ${
    // Create a Directory object containing all the files
    return {
      output_dir: {
        class: 'Directory',
        basename: inputs.dir_name,
        listing: inputs.files
      }
    };
  }
