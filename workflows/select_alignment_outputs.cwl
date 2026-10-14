cwlVersion: v1.2
class: ExpressionTool
label: Select typed outputs from the requested alignment branch

requirements:
  InlineJavascriptRequirement: {}

inputs:
  alignment_method: string
  pbmm2_mapped_bams: File[]?
  pbmm2_bam_indices: File[]?
  pbmm2_log_files: File[]?
  minimap2_mapped_bams: File[]?
  minimap2_bam_indices: File[]?
  minimap2_log_files: File[]?
  ultra_mapped_bams: File[]?
  ultra_bam_indices: File[]?
  ultra_log_files: File[]?

outputs:
  mapped_bams: File[]
  bam_indices: File[]?
  log_files: File[]?

expression: |
  ${
    var mappedBams;
    var bamIndices;
    var logFiles;

    if (inputs.alignment_method === 'pbmm2') {
      mappedBams = inputs.pbmm2_mapped_bams;
      bamIndices = inputs.pbmm2_bam_indices;
      logFiles = inputs.pbmm2_log_files;
    } else if (inputs.alignment_method === 'minimap2') {
      mappedBams = inputs.minimap2_mapped_bams;
      bamIndices = inputs.minimap2_bam_indices;
      logFiles = inputs.minimap2_log_files;
    } else if (inputs.alignment_method === 'ultra') {
      mappedBams = inputs.ultra_mapped_bams;
      bamIndices = inputs.ultra_bam_indices;
      logFiles = inputs.ultra_log_files;
    } else {
      throw new Error('Unsupported alignment method: ' + inputs.alignment_method);
    }

    if (!Array.isArray(mappedBams)) {
      throw new Error('Selected alignment output mapped_bams is not an array');
    }

    return {
      mapped_bams: mappedBams,
      bam_indices: bamIndices,
      log_files: logFiles
    };
  }
