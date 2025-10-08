cwlVersion: v1.2
class: CommandLineTool
label: Kinnex segmentation (skera split)
requirements:
  DockerRequirement:
    dockerPull: kinnex_longreads
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: run_skera.sh
        entry: |
          #!/usr/bin/env bash
          set -euo pipefail
          INPUT="$1"          # HiFi BAM input
          PRIMERS="$2"        # adapters/primers fasta
          PREFIX="$3"         # output prefix (e.g., segmented)
          THREADS="$4"        # threads
          DATASET_XML_FLAG="$5"  # true|false

          echo "skera split" >&2
          echo "input: ${INPUT}" >&2
          echo "primers: ${PRIMERS}" >&2
          echo "prefix: ${PREFIX}" >&2
          echo "threads: ${THREADS}" >&2
          echo "dataset_xml: ${DATASET_XML_FLAG}" >&2

          # Common options; --report ensures read_segmentation.report.json is produced
          OPTS=(split --report --log-level INFO --log-file skera.log --alarms alarms.json -j "${THREADS}")

          if [[ "${DATASET_XML_FLAG}" == "true" ]]; then
            # Write a ConsensusReadSet XML; skera will also emit BAMs it references
            OUT="${PREFIX}.consensusreadset.xml"
          else
            # Produce segmented BAM directly
            OUT="${PREFIX}.bam"
          fi

          echo "+ skera ${OPTS[*]} \"${INPUT}\" \"${PRIMERS}\" \"${OUT}\"" >&2
          skera "${OPTS[@]}" "${INPUT}" "${PRIMERS}" "${OUT}"

          echo "Outputs after skera run:" >&2
          ls -la >&2
baseCommand: [bash, run_skera.sh]
inputs:
  in_bam:
    type: File
    doc: HiFi BAM input (if using BAM mode)
    inputBinding:
      position: 1
  primers_fa:
    type: File
    doc: Primers/adapters FASTA (e.g., mas16_primers.fasta)
    inputBinding:
      position: 2
  out_prefix:
    type: string
    default: segmented
    inputBinding:
      position: 3
  threads:
    type: int
    default: 8
    inputBinding:
      position: 4
  use_dataset_xml:
    type: boolean
    default: false
    doc: When true, treat input as ConsensusReadSet XML and write PREFIX.consensusreadset.xml
    inputBinding:
      position: 5
outputs:
  segmented_bam:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).bam
  non_passing_bam:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).non_passing.bam
  segmented_dataset:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).consensusreadset.xml
  report_json:
    type: File?
    outputBinding:
      glob: read_segmentation.report.json
  skera_log:
    type: File?
    outputBinding:
      glob: skera.log
  alarms:
    type: File?
    outputBinding:
      glob: alarms.json
