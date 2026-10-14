cwlVersion: v1.2
class: CommandLineTool
label: Convert GTF annotation to minimap2 junction BED

requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.1
  ResourceRequirement:
    coresMin: 1
    ramMin: 4096

baseCommand: [paftools.js, gff2bed]
stdout: $(inputs.out_bed)

inputs:
  annotation_gtf:
    type: File
    doc: Transcript annotation in GTF or GFF format
    inputBinding:
      position: 1
  out_bed:
    type: string
    default: annotation.junctions.bed

outputs:
  junction_bed:
    type: File
    outputBinding:
      glob: $(inputs.out_bed)
