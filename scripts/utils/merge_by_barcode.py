#!/usr/bin/env python3
"""
Merge demultiplexed BAMs from multiple SMRTcells by barcode.

Usage:
    python3 merge_by_barcode.py <bam_list_csv> <output_basename> <num_smrt_cells> [threads]

Output filenames:
    <output_basename>.fl.<full_barcode>.merged.bam
    (BA prefix added downstream by rename_bams_with_bioassay_id)
"""
import os
import sys
import subprocess
import re
from collections import defaultdict

all_bams = sys.argv[1].split(',')
output_basename = sys.argv[2]
num_smrt_cells = int(sys.argv[3])
threads = int(sys.argv[4])

# Group BAMs by barcode key (bc\d+)
barcode_groups = defaultdict(list)
for bam_path in all_bams:
    if not bam_path.strip():
        continue
    match = re.search(r'(bc\d+)', os.path.basename(bam_path))
    if not match:
        print(f"Warning: Could not extract barcode from {bam_path}", file=sys.stderr)
        continue
    barcode_groups[match.group(1)].append(bam_path)

for barcode_key in sorted(barcode_groups.keys()):
    bam_list = barcode_groups[barcode_key]
    if len(bam_list) != num_smrt_cells:
        print(f"Warning: Expected {num_smrt_cells} BAMs for {barcode_key}, "
              f"found {len(bam_list)}", file=sys.stderr)

    # Extract full barcode name (e.g. IsoSeqX_bc04_5p--IsoSeqX_3p) from first BAM
    first_bam = os.path.basename(bam_list[0])
    bc_match = re.search(r'fl\.(.+?)\.bam', first_bam)
    full_barcode = bc_match.group(1) if bc_match else barcode_key

    output_file = f"{output_basename}.fl.{full_barcode}.merged.bam"

    cmd = ["samtools", "merge"]
    if threads > 0:
        cmd.extend(["-@", str(threads)])
    cmd += [output_file] + bam_list

    print(f"Merging {len(bam_list)} BAMs for {barcode_key} -> {output_file}...", file=sys.stderr)
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error merging {barcode_key}: {result.stderr}", file=sys.stderr)
        sys.exit(1)

print("Merge complete", file=sys.stderr)
