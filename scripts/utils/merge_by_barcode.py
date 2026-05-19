#!/usr/bin/env python3
"""
Merge demultiplexed BAMs from multiple SMRTcells by barcode using sambamba for fast merging.

Usage:
    python3 merge_by_barcode.py <bam_list_csv> <output_basename> <num_smrt_cells> [threads]

Output filenames:
    <output_basename>.fl.<full_barcode>.merged.bam
    (BA prefix added downstream by rename_bams_with_bioassay_id)

Notes:
    - Uses sambamba merge (https://lomereiter.github.io/sambamba/docs/sambamba-merge.html)
    - Threads are passed to sambamba with -t
        - Name-sorts each input with sambamba sort before merge to avoid header
            sort-order mismatches
    - For single SMRTcell, files are copied directly
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
    bam_name = os.path.basename(bam_path)
    # Parse barcode from the demux token first (fl.<token>.bam) to avoid
    # accidental matches from run prefixes/UUIDs containing bc<digits>.
    fl_match = re.search(r'fl\.(.+?)\.bam', bam_name)
    search_space = fl_match.group(1) if fl_match else bam_name
    match = re.search(r'(bc\d+)', search_space)
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

    if len(bam_list) == 1:
        print(f"Single SMRTcell for {barcode_key}, copying {bam_list[0]} -> {output_file}...", file=sys.stderr)
        subprocess.run(["cp", bam_list[0], output_file], check=True)
        continue

    print(
        f"Sorting {len(bam_list)} BAMs for {barcode_key} with sambamba sort (name sort) before merge...",
        file=sys.stderr,
    )
    sorted_bams = []
    for idx, in_bam in enumerate(bam_list):
        sort_out = f"{barcode_key}.{idx}.namesorted.bam"
        sort_cmd = ["sambamba", "sort"]
        if threads > 0:
            sort_cmd.extend(["-t", str(threads)])
        sort_cmd.extend(["-n", "-o", sort_out, in_bam])
        sort_result = subprocess.run(sort_cmd, capture_output=True, text=True)
        if sort_result.returncode != 0:
            print(
                f"Error sorting {in_bam} for {barcode_key}: {sort_result.stderr}",
                file=sys.stderr,
            )
            sys.exit(1)
        sorted_bams.append(sort_out)

    merge_cmd = ["sambamba", "merge"]
    if threads > 0:
        merge_cmd.extend(["-t", str(threads)])
    merge_cmd += [output_file] + sorted_bams

    print(
        f"Merging {len(sorted_bams)} name-sorted BAMs for {barcode_key} -> {output_file} using sambamba...",
        file=sys.stderr,
    )
    merge_result = subprocess.run(merge_cmd, capture_output=True, text=True)
    if merge_result.returncode != 0:
        print(f"Error merging {barcode_key} with sambamba: {merge_result.stderr}", file=sys.stderr)
        sys.exit(1)

print("Merge complete", file=sys.stderr)
