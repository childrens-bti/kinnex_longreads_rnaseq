cwlVersion: v1.2
class: CommandLineTool
label: Kinnex segmentation (skera split)
requirements:
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0
  ShellCommandRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: run_skera.sh
        entry: |
          #!/usr/bin/env bash
          set -euo pipefail
          INPUT=$1
          ADAPTERS=$2
          PREFIX=$3
          THREADS=$4
          # CWL may omit boolean false and other optional args
          OUTPUT_XML_FLAG="true"  # true|false -> choose .xml vs .bam
          LOG_LEVEL=""
          LOG_FILE=""
          if [ "$#" -ge 5 ]; then OUTPUT_XML_FLAG="$5"; fi
          if [ "$#" -ge 6 ]; then LOG_LEVEL="$6"; fi
          if [ "$#" -ge 7 ]; then LOG_FILE="$7"; fi

          echo "skera split" >&2
          echo "input: $INPUT" >&2
          echo "adapters: $ADAPTERS" >&2
          echo "prefix: $PREFIX" >&2
          echo "threads: $THREADS" >&2
          echo "output_xml: $OUTPUT_XML_FLAG" >&2
          if [[ -n "$LOG_LEVEL" ]]; then echo "log-level: $LOG_LEVEL" >&2; fi
          if [[ -n "$LOG_FILE" ]]; then echo "log-file: $LOG_FILE" >&2; fi

          # Build options per 'skera split -h'
          OPTS="split -j $THREADS"
          if [[ -n "$LOG_LEVEL" ]]; then
            OPTS="$OPTS --log-level $LOG_LEVEL"
          fi
          # Always write a log file in the working directory for CWL to collect
          if [[ -z "$LOG_FILE" ]]; then
            LOG_FILE="skera.log"
          fi
          OPTS="$OPTS --log-file $LOG_FILE"

          if [[ "$OUTPUT_XML_FLAG" == "true" ]]; then
            OUT="$PREFIX.consensusreadset.xml"
          else
            OUT="$PREFIX.bam"
          fi

          echo "+ skera $OPTS \"$INPUT\" \"$ADAPTERS\" \"$OUT\"" >&2
          # shellcheck disable=SC2086
          skera $OPTS "$INPUT" "$ADAPTERS" "$OUT"


          echo "Outputs after skera run:" >&2
          ls -la >&2
baseCommand: [bash, run_skera.sh]
inputs:
  in_bam:
    type: File
    doc: Input dataset (BAM or ConsensusReadSet XML)
    inputBinding:
      position: 1
  adapters_fa:
    type: File
    doc: Adapters FASTA or AdapterSet XML (per skera split)
    inputBinding:
      position: 2
  out_prefix:
    type: string?
    default: segmented
    inputBinding:
      position: 3
  threads:
    type: int?
    default: 0
    inputBinding:
      position: 4
  use_dataset_xml:
    type: boolean?
    default: true
    doc: When true, write PREFIX.consensusreadset.xml (else PREFIX.bam)
    inputBinding:
      position: 5
      valueFrom: |
        $(self ? 'true' : 'false')
  log_level:
    type: string?
    doc: Set log level (TRACE, DEBUG, INFO, WARN, FATAL)
    inputBinding:
      position: 6
  log_file:
    type: string?
    doc: Log to a file instead of stderr (path)
    inputBinding:
      position: 7
outputs:
  segmented_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_prefix).bam
    secondaryFiles:
      - .pbi
  non_passing_bam:
    type: File
    outputBinding:
      glob: $(inputs.out_prefix).non_passing.bam
    secondaryFiles:
      - .pbi
  segmented_dataset:
    type: File?
    doc: ConsensusReadSet XML (only created when use_dataset_xml=true and may not be output by skera)
    outputBinding:
      glob: $(inputs.out_prefix).consensusreadset.xml
  summary_csv:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).summary.csv
  ligations_csv:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).ligations.csv
  read_lengths_csv:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).read_lengths.csv
  adapters_csv_gz:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix).found_adapters.csv.gz
