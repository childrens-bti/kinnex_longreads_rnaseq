cwlVersion: v1.2
class: CommandLineTool
label: Parse manifest TSV to create barcode-to-Bioassay_ID mapping

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: parse_manifest.py
        entry: |
          #!/usr/bin/env python3
          import sys
          import csv
          import json
          import re
          
          manifest_file = sys.argv[1]
          output_file = sys.argv[2]
          
          # Parse manifest and create mapping
          barcode_to_id = {}
          
          with open(manifest_file, 'r') as f:
              reader = csv.DictReader(f, delimiter='\t')
              for row in reader:
                  filename = row.get('file_name', '')
                  bioassay_id = row.get('Bioassay_ID', '')
                  
                  # Extract barcode from filename pattern: fl.<barcode>.bam
                  # Matches anything between "fl." and ".bam"
                  match = re.search(r'fl\.(.+?)\.bam', filename)
                  if match and bioassay_id:
                      barcode = match.group(1)
                      barcode_to_id[barcode] = bioassay_id
                      print(f"Mapped: {barcode} -> {bioassay_id}")
          
          # Write JSON mapping
          with open(output_file, 'w') as f:
              json.dump(barcode_to_id, f, indent=2)
          
          print(f"Created mapping for {len(barcode_to_id)} barcodes")

baseCommand: [python3, parse_manifest.py]

inputs:
  manifest:
    type: File?
    doc: Manifest TSV file with file_name and Bioassay_ID columns
    inputBinding:
      position: 1

arguments:
  - position: 2
    valueFrom: barcode_to_bioassay_mapping.json

outputs:
  barcode_mapping:
    type: File
    outputBinding:
      glob: barcode_to_bioassay_mapping.json
