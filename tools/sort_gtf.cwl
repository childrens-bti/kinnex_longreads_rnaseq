cwlVersion: v1.2
class: CommandLineTool
label: Sort GTF records by chromosome and genomic coordinates

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  EnvVarRequirement:
    envDef:
      LC_ALL: C
  ResourceRequirement:
    coresMin: 1
    ramMin: 16000

baseCommand: [sort]

arguments:
  - "-k1,1"
  - "-k4,4n"
  - "-k5,5n"

inputs:
  annotation_gtf:
    type: File
    doc: GTF annotation to sort before uLTRA index construction
    inputBinding:
      position: 1
  out_gtf:
    type: string
    default: annotation.coordinate_sorted.gtf

stdout: $(inputs.out_gtf)

outputs:
  sorted_gtf:
    type: File
    outputBinding:
      glob: $(inputs.out_gtf)
