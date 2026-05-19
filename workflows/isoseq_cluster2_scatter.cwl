cwlVersion: v1.2
class: Workflow

label: Scatter isoseq cluster2 across multiple FLNC BAMs
requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  flnc_bams: File[]
  threads:
    type: int?
    default: 0
  log_level:
    type: string?
    default: INFO
  singletons:
    type: boolean?
    default: false
  write_bam:
    type: boolean?
    default: false
    doc: If true, write annotated BAM file

  cluster_ram_gb:
    type: int?
    default: 48
    doc: RAM in GB for ResourceRequirement (set by parent workflow)

steps:
  cluster_each:
    run: ../tools/isoseq_cluster2.cwl
    in:
      flnc_input: flnc_bams
      transcripts_bam:
        valueFrom: $(inputs.flnc_input.basename.replace(/\.bam$/, '').replace(/\.flnc\./, '.clustered.') + '.transcripts.bam')
      threads: threads
      log_level: log_level
      log_file:
        valueFrom: $(inputs.flnc_input.basename.replace(/\.bam$/, '').replace(/\.flnc\./, '.clustered.') + '.isoseq-cluster2.log')
      singletons: singletons
      write_bam:
        valueFrom: |
          ${
            if (inputs.write_bam === true) {
              return inputs.flnc_input.basename.replace(/\.bam$/, '').replace(/\.flnc\./, '.clustered.') + '.annotated.bam';
            }
            return null;
          }

    out: [transcripts_output, singletons_output, annotated_bam, report_csv]
    scatter: flnc_input
    scatterMethod: dotproduct

outputs:
  transcripts_bams:
    type: File[]
    outputSource: cluster_each/transcripts_output
  singletons_outputs:
    type: File[]?
    outputSource: cluster_each/singletons_output
  annotated_bams:
    type: File[]?
    outputSource: cluster_each/annotated_bam
  report_csvs:
    type: File[]?
    outputSource: cluster_each/report_csv
