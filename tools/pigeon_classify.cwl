cwlVersion: v1.2
class: CommandLineTool
label: Pigeon classify
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
baseCommand: [pigeon, classify]
inputs:
  collapse_gff:
    type: File
    inputBinding:
      position: 1
  reference_fa:
    type: File
    inputBinding:
      position: 2
  annotation_gtf:
    type: File
    inputBinding:
      position: 3
  fl_count:
    type: File?
    inputBinding:
      prefix: --fl
      position: 4
stdout: pigeon_classify.stdout.txt
stderr: pigeon_classify.stderr.txt
outputs:
  pigeon_sorted_gff:
    type: File
    outputBinding:
      glob: pigeon.sorted-*.gff
