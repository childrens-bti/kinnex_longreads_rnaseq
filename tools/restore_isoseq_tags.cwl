cwlVersion: v1.2
class: CommandLineTool
label: Restore Iso-Seq transcript tags after FASTQ-based alignment

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  InitialWorkDirRequirement:
    listing:
      - entryname: restore_isoseq_tags.py
        entry: |
          import subprocess
          import sys

          source_bam, mapped_sam, output_sam = sys.argv[1:]
          tags_by_read = {}
          wanted_tags = {"is", "im", "zm", "RG"}

          read_group_headers = subprocess.check_output(
              ["samtools", "view", "-H", source_bam], text=True
          )
          read_group_headers = [
              line for line in read_group_headers.splitlines() if line.startswith("@RG\t")
          ]

          with subprocess.Popen(
              ["samtools", "view", source_bam], text=True, stdout=subprocess.PIPE
          ) as source:
              for line in source.stdout:
                  fields = line.rstrip("\n").split("\t")
                  tags = [
                      field
                      for field in fields[11:]
                      if field.split(":", 1)[0] in wanted_tags
                  ]
                  if tags:
                      tags_by_read[fields[0]] = tags

          with open(mapped_sam, encoding="utf-8") as source, open(
              output_sam, "w", encoding="utf-8"
          ) as destination:
              wrote_read_groups = False
              for line in source:
                  if line.startswith("@"):
                      destination.write(line)
                      continue

                  if not wrote_read_groups:
                      for read_group in read_group_headers:
                          destination.write(read_group + "\n")
                      wrote_read_groups = True

                  fields = line.rstrip("\n").split("\t")
                  existing_tags = {field.split(":", 1)[0] for field in fields[11:]}
                  fields.extend(
                      tag
                      for tag in tags_by_read.get(fields[0], [])
                      if tag.split(":", 1)[0] not in existing_tags
                  )
                  if "mg" not in existing_tags:
                      divergence = next(
                          (
                              float(field.split(":", 2)[2])
                              for field in fields[11:]
                              if field.startswith("de:f:")
                          ),
                          None,
                      )
                      if divergence is not None:
                          fields.append(f"mg:f:{100 * (1 - divergence):.4f}")
                  destination.write("\t".join(fields) + "\n")
  InlineJavascriptRequirement: {}

baseCommand: [python3, restore_isoseq_tags.py]

inputs:
  source_bam:
    type: File
    doc: Clustered transcript BAM containing Iso-Seq provenance tags.
    inputBinding:
      position: 1
  mapped_sam:
    type: File
    doc: SAM emitted by minimap2 from the transcript FASTQ.
    inputBinding:
      position: 2
  out_sam:
    type: string
    default: mapped.minimap2.tagged.sam
    inputBinding:
      position: 3

outputs:
  tagged_sam:
    type: File
    outputBinding:
      glob: $(inputs.out_sam)
