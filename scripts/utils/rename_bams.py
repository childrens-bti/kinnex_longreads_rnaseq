#!/usr/bin/env python3
"""
Rename BAM files with Bioassay ID prefix using a barcode mapping JSON.

Usage:
    python3 rename_bams.py <barcode_mapping.json>

Input BAMs must be present in the current working directory.
Expects filenames containing: fl.<barcode>[.merged].bam
Output: [prefix.]<bioassay_id>.fl.<barcode>[.merged].bam
"""
import sys
import json
import os
import shutil
import re

mapping_file = sys.argv[1]

with open(mapping_file, 'r') as f:
    mapping = json.load(f)

renamed_files = []
for filename in os.listdir('.'):
    if not filename.endswith('.bam'):
        continue
    match = re.search(r'fl\.(.+?)(?:\.merged)?\.bam', filename)
    if match:
        barcode = match.group(1)
        bioassay_id = mapping.get(barcode)

        if bioassay_id:
            prefix = filename[:match.start()]
            rest = filename[match.start():]
            new_name = f"{prefix}{bioassay_id}.{rest}"
            shutil.move(filename, new_name)
            print(f"Renamed: {filename} -> {new_name}")
            renamed_files.append(new_name)

            pbi_old = filename + '.pbi'
            pbi_new = new_name + '.pbi'
            if os.path.exists(pbi_old):
                shutil.move(pbi_old, pbi_new)
                print(f"Renamed index: {pbi_old} -> {pbi_new}")
        else:
            print(f"Warning: No Bioassay_ID found for barcode {barcode}, keeping original name")
            renamed_files.append(filename)
    else:
        print(f"Warning: {filename} doesn't match expected pattern fl.<barcode>.bam")
        renamed_files.append(filename)

print(f"\nTotal files processed: {len(renamed_files)}")
