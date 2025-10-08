cwlVersion: v1.2
class: Workflow
label: Kinnex/MAS-Iso-Seq long-read pipeline

requirements:
	SubworkflowFeatureRequirement: {}
	StepInputExpressionRequirement: {}
	InlineJavascriptRequirement: {}
	DockerRequirement:
		dockerPull: kinnex_longreads

inputs:
	hifi_dir:
		type: Directory
		default:
			class: Directory
			path: data/bti-private-us-east-1-prd-rokita-lab/source/SR009023_Kinnex/SMRTcell1/hifi_reads
	primers_fa: File
	reference_fa: File
	annotation_gtf: File

outputs:
	filtered_gff:
		type: File
		outputSource: pigeon_filter/pigeon_filtered_gff
	collapse_gff:
		type: File
		outputSource: isoseq_collapse/collapse_gff
	mapped_bam:
		type: File
		outputSource: pbmm2/mapped_bam
	transcripts_fa:
		type: File
		outputSource: cluster/transcripts_fa

steps:
	skera:
		run: workflows/skera.cwl
		in:
			hifi_dir: hifi_dir
			out_prefix: { default: segmented }
		out: [segmented_bam, non_passing_bam, report_json]

	lima:
		run: tools/lima_isoseq.cwl
		in:
			segmented_bam: skera/segmented_bam
			primers_fa: primers_fa
			out_bam: { default: fl_transcripts.bam }
		out: [demux_bam]

	refine:
		run: tools/isoseq_refine.cwl
		in:
			in_bam: lima/demux_bam
			primers_fa: primers_fa
			out_bam: { default: flnc-1.bam }
		out: [flnc_bam]

	cluster:
		run: tools/isoseq_cluster2.cwl
		in:
			flnc_bam: refine/flnc_bam
			out_fasta: { default: transcripts-1.fasta }
		out: [transcripts_fa]

	pbmm2:
		run: tools/pbmm2_align.cwl
		in:
			reference_fa: reference_fa
			transcripts_fa: cluster/transcripts_fa
			out_bam: { default: mapped-1.bam }
		out: [mapped_bam]

	isoseq_collapse:
		run: tools/isoseq_collapse.cwl
		in:
			mapped_bam: pbmm2/mapped_bam
			out_gff: { default: collapse_isoforms-1.gff }
		out: [collapse_gff]

	pigeon_classify:
		run: tools/pigeon_classify.cwl
		in:
			collapse_gff: isoseq_collapse/collapse_gff
			reference_fa: reference_fa
			annotation_gtf: annotation_gtf
		out: [pigeon_sorted_gff]

	pigeon_filter:
		run: tools/pigeon_filter.cwl
		in:
			pigeon_sorted_gff: pigeon_classify/pigeon_sorted_gff
			isoforms_fa: cluster/transcripts_fa
		out: [pigeon_filtered_gff]