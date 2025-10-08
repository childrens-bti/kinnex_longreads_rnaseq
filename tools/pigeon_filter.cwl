cwlVersion: v1.2
class: CommandLineTool
label: Pigeon filter
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [pigeon, filter]
inputs:
  pigeon_sorted_gff:
    type: File
    inputBinding:
      position: 1
  isoforms_fa:
    type: File
    inputBinding:
      prefix: --isoforms
      position: 2
stdout: pigeon_filter.stdout.txt
stderr: pigeon_filter.stderr.txt
outputs:
  pigeon_filtered_gff:
    type: File
    outputBinding:
      glob: pigeon_filtered.sorted-*.gff
