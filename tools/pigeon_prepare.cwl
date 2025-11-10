cwlVersion: v1.2
class: CommandLineTool
label: Pigeon prepare - Prepare classification input files
requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: $(inputs.input_files)

baseCommand: [pigeon, prepare]

inputs:
  input_files:
    type: File[]
    doc: >
      Input file(s) for pigeon classify. These include reference annotations GTF/GFF,
      reference sequence FASTA, and any supplemental data in BED/TSV formats.
    inputBinding:
      position: 1
      valueFrom: |
        ${return self.map(function(f) { return f.basename; });}
  
  log_level:
    type: string
    default: WARN
    doc: Set log level
    inputBinding:
      prefix: --log-level
  log_file:
    type: string?
    doc: Log to a file, instead of stderr
    inputBinding:
      prefix: --log-file

outputs:
  prepared_annotation:
    type: File?
    doc: Prepared annotation GTF file with .pgi index (only when GTF input is provided)
    outputBinding:
      glob: "*.sorted.gtf"
    secondaryFiles:
      - .pgi
  
  prepared_isoforms:
    type: File?
    doc: Prepared isoforms GFF file with .pgi index (only when GFF input is provided)
    outputBinding:
      glob: "*.sorted.gff"
    secondaryFiles:
      - .pgi
  
  prepared_reference:
    type: File?
    doc: Reference FASTA with .fai index (only when FASTA input is provided)
    outputBinding:
      glob: |
        ${
          // Find the FASTA file from input_files and return its basename
          for (var i = 0; i < inputs.input_files.length; i++) {
            var fname = inputs.input_files[i].basename;
            if (fname.endsWith('.fa') || fname.endsWith('.fasta')) {
              return fname;
            }
          }
          return null;
        }
    secondaryFiles:
      - .fai
  log_file_output:
    type: File?
    outputBinding:
      glob: "${ return inputs.log_file ? inputs.log_file : []; }"
