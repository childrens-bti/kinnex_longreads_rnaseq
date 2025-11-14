cwlVersion: v1.2
class: CommandLineTool
label: Rename BAM files with Bioassay ID prefix

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.input_bams)
        writable: true
      - entryname: rename_bams.py
        entry: |
          #!/usr/bin/env python3
          import sys
          import json
          import os
          import shutil
          import re
          
          mapping_file = sys.argv[1]
          
          # Load barcode to Bioassay_ID mapping
          with open(mapping_file, 'r') as f:
              mapping = json.load(f)
          
          # Find and rename BAM files
          renamed_files = []
          for filename in os.listdir('.'):
              if filename.endswith('.bam'):
                  # Extract barcode from filename pattern: fl.<barcode>.bam
                  # Matches anything between "fl." and ".bam"
                  match = re.search(r'fl\.(.+?)\.bam', filename)
                  if match:
                      barcode = match.group(1)
                      bioassay_id = mapping.get(barcode)
                      
                      if bioassay_id:
                          # New name: BA_ID.original_name
                          new_name = f"{bioassay_id}.{filename}"
                          shutil.move(filename, new_name)
                          print(f"Renamed: {filename} -> {new_name}")
                          renamed_files.append(new_name)
                          
                          # Also rename .pbi index if exists
                          pbi_old = filename + '.pbi'
                          pbi_new = new_name + '.pbi'
                          if os.path.exists(pbi_old):
                              shutil.move(pbi_old, pbi_new)
                              print(f"Renamed index: {pbi_old} -> {pbi_new}")
                      else:
                          print(f"Warning: No Bioassay_ID found for barcode {barcode}, keeping original name")
                          renamed_files.append(filename)
                  else:
                      # Keep files that don't match pattern
                      print(f"Warning: File {filename} doesn't match expected pattern fl.<barcode>.bam")
                      renamed_files.append(filename)
          
          print(f"\nTotal files processed: {len(renamed_files)}")

baseCommand: [python3, rename_bams.py]

inputs:
  input_bams:
    type: File[]
    secondaryFiles:
      - pattern: .pbi
        required: false
  barcode_mapping:
    type: File?
    inputBinding:
      position: 1

outputs:
  renamed_bams:
    type: File[]
    outputBinding:
      glob: "*.bam"
    secondaryFiles:
      - pattern: .pbi
        required: false
