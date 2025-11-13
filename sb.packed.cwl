{
    "$graph": [
        {
            "class": "Workflow",
            "label": "Kinnex/MAS-Iso-Seq Complete Long-Read Pipeline",
            "doc": "Complete end-to-end pipeline for PacBio Kinnex/MAS-Iso-Seq long-read transcriptome analysis.\n\nPipeline Steps:\n1. Skera: Segment HiFi reads into individual transcripts\n2. Lima: Demultiplex segmented reads by barcodes\n3. IsoSeq Refine: Trim and filter full-length non-concatemer (FLNC) reads\n4. IsoSeq Cluster2: Cluster FLNC reads into transcript models\n5. PBMM2: Align transcript models to reference genome\n6. IsoSeq Collapse: Collapse aligned reads into unique isoforms\n7. Pigeon Classify: Classify isoforms based on reference annotation\n8. Pigeon Filter & Report: Filter classified isoforms and generate saturation reports\n",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Adapters FASTA file (e.g., mas8_primers.fasta)",
                    "id": "#main/adapters_fa"
                },
                {
                    "type": "File",
                    "doc": "Reference annotation GTF file",
                    "id": "#main/annotation_gtf"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "pigeon",
                    "doc": "Base prefix for pigeon classify output files",
                    "id": "#main/classify_out_prefix_base"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/classify_threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#main/cluster_singletons"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/cluster_threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#main/collapse_do_not_collapse_extra_5exons"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 100,
                    "id": "#main/collapse_max_3p_diff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "id": "#main/collapse_max_5p_diff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 5,
                    "id": "#main/collapse_max_fuzzy_junction"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.99,
                    "id": "#main/collapse_min_aln_coverage"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.95,
                    "id": "#main/collapse_min_aln_identity"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/collapse_threads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "id": "#main/filter_max_distance"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 3,
                    "id": "#main/filter_min_cov"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#main/filter_mono_exon"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.6,
                    "id": "#main/filter_polya_percent"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 6,
                    "id": "#main/filter_polya_run_length"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#main/filter_skip_junctions"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/filter_threads"
                },
                {
                    "type": "File",
                    "doc": "HiFi BAM file containing reads to segment",
                    "secondaryFiles": [
                        {
                            "required": false,
                            "pattern": ".pbi"
                        }
                    ],
                    "id": "#main/hifi_bam"
                },
                {
                    "type": "File",
                    "doc": "Barcode/Primer FASTA for lima demultiplexing",
                    "id": "#main/lima_barcodes"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "fl",
                    "id": "#main/lima_out_prefix"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/lima_threads"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "INFO",
                    "id": "#main/log_level"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "BAM index type for sorted output (NONE, BAI, CSI). If not specified, uses pbmm2 default.",
                    "id": "#main/pbmm2_bam_index"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 95.0,
                    "id": "#main/pbmm2_min_gap_comp_id_perc"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "ISOSEQ",
                    "id": "#main/pbmm2_preset"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#main/pbmm2_sort"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/pbmm2_threads"
                },
                {
                    "type": "File",
                    "doc": "Reference genome FASTA file",
                    "id": "#main/reference_fa"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#main/refine_require_polya"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/refine_threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#main/report_exclude_singletons"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/report_sub_sample_increment"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/report_threads"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "segmented",
                    "id": "#main/skera_out_prefix"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#main/skera_threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#main/skera_use_dataset_xml"
                }
            ],
            "steps": [
                {
                    "run": "#pigeon_classify_scatter.cwl",
                    "in": [
                        {
                            "source": "#main/annotation_gtf",
                            "id": "#main/classify/annotation_gtf"
                        },
                        {
                            "source": "#main/collapse/collapse_gffs",
                            "id": "#main/classify/collapse_gffs"
                        },
                        {
                            "source": "#main/collapse/flnc_count_txts",
                            "id": "#main/classify/flnc_counts"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/classify/log_level"
                        },
                        {
                            "source": "#main/classify_out_prefix_base",
                            "id": "#main/classify/out_prefix_base"
                        },
                        {
                            "source": "#main/reference_fa",
                            "id": "#main/classify/reference_fa"
                        },
                        {
                            "source": "#main/classify_threads",
                            "id": "#main/classify/threads"
                        }
                    ],
                    "out": [
                        "#main/classify/classification_txts",
                        "#main/classify/junctions_txts",
                        "#main/classify/report_jsons",
                        "#main/classify/summary_txts",
                        "#main/classify/prepared_isoforms_gffs"
                    ],
                    "id": "#main/classify"
                },
                {
                    "run": "#isoseq_cluster2_scatter.cwl",
                    "in": [
                        {
                            "source": "#main/refine/out_flnc_bams",
                            "id": "#main/cluster/flnc_bams"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/cluster/log_level"
                        },
                        {
                            "source": "#main/cluster_singletons",
                            "id": "#main/cluster/singletons"
                        },
                        {
                            "source": "#main/cluster_threads",
                            "id": "#main/cluster/threads"
                        }
                    ],
                    "out": [
                        "#main/cluster/transcripts_bams",
                        "#main/cluster/singletons_outputs",
                        "#main/cluster/annotated_bams",
                        "#main/cluster/report_csvs"
                    ],
                    "id": "#main/cluster"
                },
                {
                    "run": "#isoseq_collapse_scatter.cwl",
                    "in": [
                        {
                            "source": "#main/pbmm2/mapped_bams",
                            "id": "#main/collapse/aligned_bams"
                        },
                        {
                            "source": "#main/collapse_do_not_collapse_extra_5exons",
                            "id": "#main/collapse/do_not_collapse_extra_5exons"
                        },
                        {
                            "source": "#main/refine/out_flnc_bams",
                            "id": "#main/collapse/flnc_bams"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/collapse/log_level"
                        },
                        {
                            "source": "#main/collapse_max_3p_diff",
                            "id": "#main/collapse/max_3p_diff"
                        },
                        {
                            "source": "#main/collapse_max_5p_diff",
                            "id": "#main/collapse/max_5p_diff"
                        },
                        {
                            "source": "#main/collapse_max_fuzzy_junction",
                            "id": "#main/collapse/max_fuzzy_junction"
                        },
                        {
                            "source": "#main/collapse_min_aln_coverage",
                            "id": "#main/collapse/min_aln_coverage"
                        },
                        {
                            "source": "#main/collapse_min_aln_identity",
                            "id": "#main/collapse/min_aln_identity"
                        },
                        {
                            "source": "#main/collapse_threads",
                            "id": "#main/collapse/threads"
                        }
                    ],
                    "out": [
                        "#main/collapse/collapse_gffs",
                        "#main/collapse/collapse_fastas",
                        "#main/collapse/group_txts",
                        "#main/collapse/flnc_count_txts",
                        "#main/collapse/read_stat_txts",
                        "#main/collapse/collapse_report_jsons",
                        "#main/collapse/abundance_txts"
                    ],
                    "id": "#main/collapse"
                },
                {
                    "run": "#pigeon_filter_report_scatter.cwl",
                    "in": [
                        {
                            "source": "#main/classify/classification_txts",
                            "id": "#main/filter_report/classification_txts"
                        },
                        {
                            "source": "#main/report_exclude_singletons",
                            "id": "#main/filter_report/exclude_singletons"
                        },
                        {
                            "source": "#main/filter_threads",
                            "id": "#main/filter_report/filter_threads"
                        },
                        {
                            "source": "#main/classify/prepared_isoforms_gffs",
                            "id": "#main/filter_report/isoforms_gffs"
                        },
                        {
                            "source": "#main/classify/junctions_txts",
                            "id": "#main/filter_report/junctions_txts"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/filter_report/log_level"
                        },
                        {
                            "source": "#main/filter_max_distance",
                            "id": "#main/filter_report/max_distance"
                        },
                        {
                            "source": "#main/filter_min_cov",
                            "id": "#main/filter_report/min_cov"
                        },
                        {
                            "source": "#main/filter_mono_exon",
                            "id": "#main/filter_report/mono_exon"
                        },
                        {
                            "source": "#main/filter_polya_percent",
                            "id": "#main/filter_report/polya_percent"
                        },
                        {
                            "source": "#main/filter_polya_run_length",
                            "id": "#main/filter_report/polya_run_length"
                        },
                        {
                            "source": "#main/report_threads",
                            "id": "#main/filter_report/report_threads"
                        },
                        {
                            "source": "#main/filter_skip_junctions",
                            "id": "#main/filter_report/skip_junctions"
                        },
                        {
                            "source": "#main/report_sub_sample_increment",
                            "id": "#main/filter_report/sub_sample_increment"
                        }
                    ],
                    "out": [
                        "#main/filter_report/filtered_classification_txts",
                        "#main/filter_report/filtered_junctions_txts",
                        "#main/filter_report/filtered_reasons_txts",
                        "#main/filter_report/filtered_gffs",
                        "#main/filter_report/filtered_report_jsons",
                        "#main/filter_report/filtered_summary_txts",
                        "#main/filter_report/saturation_txts"
                    ],
                    "id": "#main/filter_report"
                },
                {
                    "run": "#lima_isoseq_run.cwl",
                    "in": [
                        {
                            "source": "#main/lima_barcodes",
                            "id": "#main/lima/barcodes"
                        },
                        {
                            "source": "#main/skera/segmented_bam",
                            "id": "#main/lima/in_dataset"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/lima/log_level"
                        },
                        {
                            "source": "#main/lima_out_prefix",
                            "id": "#main/lima/out_prefix"
                        },
                        {
                            "source": "#main/lima_threads",
                            "id": "#main/lima/threads"
                        }
                    ],
                    "out": [
                        "#main/lima/out_dataset",
                        "#main/lima/demux_bams",
                        "#main/lima/demux_bam_pbis",
                        "#main/lima/counts",
                        "#main/lima/report",
                        "#main/lima/summary",
                        "#main/lima/lima_log"
                    ],
                    "id": "#main/lima"
                },
                {
                    "run": "#pbmm2_align_scatter.cwl",
                    "in": [
                        {
                            "source": "#main/pbmm2_bam_index",
                            "id": "#main/pbmm2/bam_index"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/pbmm2/log_level"
                        },
                        {
                            "source": "#main/pbmm2_min_gap_comp_id_perc",
                            "id": "#main/pbmm2/min_gap_comp_id_perc"
                        },
                        {
                            "source": "#main/pbmm2_preset",
                            "id": "#main/pbmm2/preset"
                        },
                        {
                            "source": "#main/reference_fa",
                            "id": "#main/pbmm2/reference"
                        },
                        {
                            "source": "#main/pbmm2_sort",
                            "id": "#main/pbmm2/sort"
                        },
                        {
                            "source": "#main/pbmm2_threads",
                            "id": "#main/pbmm2/threads"
                        },
                        {
                            "source": "#main/cluster/transcripts_bams",
                            "id": "#main/pbmm2/transcript_bams"
                        }
                    ],
                    "out": [
                        "#main/pbmm2/mapped_bams",
                        "#main/pbmm2/log_files"
                    ],
                    "id": "#main/pbmm2"
                },
                {
                    "run": "#isoseq_refine_scatter.cwl",
                    "in": [
                        {
                            "source": "#main/lima_barcodes",
                            "id": "#main/refine/barcodes"
                        },
                        {
                            "source": "#main/lima/demux_bams",
                            "id": "#main/refine/demux_bams"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/refine/log_level"
                        },
                        {
                            "source": "#main/refine_require_polya",
                            "id": "#main/refine/require_polya"
                        },
                        {
                            "source": "#main/refine_threads",
                            "id": "#main/refine/threads"
                        }
                    ],
                    "out": [
                        "#main/refine/out_flnc_bams",
                        "#main/refine/filter_summaries",
                        "#main/refine/reports"
                    ],
                    "id": "#main/refine"
                },
                {
                    "run": "#skera.cwl",
                    "in": [
                        {
                            "source": "#main/adapters_fa",
                            "id": "#main/skera/adapters_fa"
                        },
                        {
                            "source": "#main/hifi_bam",
                            "id": "#main/skera/hifi_bam"
                        },
                        {
                            "source": "#main/log_level",
                            "id": "#main/skera/log_level"
                        },
                        {
                            "source": "#main/skera_out_prefix",
                            "id": "#main/skera/out_prefix"
                        },
                        {
                            "source": "#main/skera_threads",
                            "id": "#main/skera/threads"
                        },
                        {
                            "source": "#main/skera_use_dataset_xml",
                            "id": "#main/skera/use_dataset_xml"
                        }
                    ],
                    "out": [
                        "#main/skera/segmented_bam",
                        "#main/skera/non_passing_bam",
                        "#main/skera/segmented_dataset",
                        "#main/skera/summary_csv",
                        "#main/skera/ligations_csv",
                        "#main/skera/read_lengths_csv",
                        "#main/skera/adapters_csv_gz"
                    ],
                    "id": "#main/skera"
                }
            ],
            "id": "#main",
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/skera/adapters_csv_gz",
                    "id": "#main/adapters_csv_gz"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/classify/classification_txts",
                    "id": "#main/classification_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/classify/report_jsons",
                    "id": "#main/classify_reports"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/classify/summary_txts",
                    "id": "#main/classify_summaries"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/cluster/annotated_bams",
                    "id": "#main/cluster_annotated_bams"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/cluster/report_csvs",
                    "id": "#main/cluster_reports"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/cluster/singletons_outputs",
                    "id": "#main/cluster_singletons_outputs"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/collapse/abundance_txts",
                    "id": "#main/collapse_abundance_txts"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/collapse/collapse_fastas",
                    "id": "#main/collapse_fastas"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/collapse/collapse_gffs",
                    "id": "#main/collapse_gffs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/collapse/group_txts",
                    "id": "#main/collapse_group_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/collapse/read_stat_txts",
                    "id": "#main/collapse_read_stat_txts"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/collapse/collapse_report_jsons",
                    "id": "#main/collapse_reports"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/lima/demux_bam_pbis",
                    "id": "#main/demux_bam_pbis"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/lima/demux_bams",
                    "id": "#main/demux_bams"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/filter_report/filtered_classification_txts",
                    "doc": "Quality-filtered transcript classifications",
                    "id": "#main/filtered_classification_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": [
                            "File",
                            "null"
                        ]
                    },
                    "outputSource": "#main/filter_report/filtered_gffs",
                    "doc": "Quality-filtered isoform annotations (recommended for downstream analysis)",
                    "id": "#main/filtered_gffs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/filter_report/filtered_junctions_txts",
                    "doc": "Quality-filtered junction information",
                    "id": "#main/filtered_junctions_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/filter_report/filtered_reasons_txts",
                    "doc": "Filtering reason codes",
                    "id": "#main/filtered_reasons_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/filter_report/filtered_report_jsons",
                    "doc": "Comprehensive filtering statistics",
                    "id": "#main/filtered_reports"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/filter_report/filtered_summary_txts",
                    "doc": "Summary filtering metrics",
                    "id": "#main/filtered_summaries"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/refine/out_flnc_bams",
                    "id": "#main/flnc_bams"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/collapse/flnc_count_txts",
                    "id": "#main/flnc_count_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/classify/junctions_txts",
                    "id": "#main/junctions_txts"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/skera/ligations_csv",
                    "id": "#main/ligations_csv"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/lima/counts",
                    "id": "#main/lima_counts"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/lima/lima_log",
                    "id": "#main/lima_log"
                },
                {
                    "type": "File",
                    "outputSource": "#main/lima/out_dataset",
                    "id": "#main/lima_out_dataset"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/lima/report",
                    "id": "#main/lima_report"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/lima/summary",
                    "id": "#main/lima_summary"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/pbmm2/mapped_bams",
                    "id": "#main/mapped_bams"
                },
                {
                    "type": "File",
                    "outputSource": "#main/skera/non_passing_bam",
                    "id": "#main/non_passing_bam"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/pbmm2/log_files",
                    "id": "#main/pbmm2_log_files"
                },
                {
                    "type": {
                        "type": "array",
                        "items": [
                            "null",
                            "File"
                        ]
                    },
                    "outputSource": "#main/classify/prepared_isoforms_gffs",
                    "id": "#main/prepared_isoforms_gffs"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/skera/read_lengths_csv",
                    "id": "#main/read_lengths_csv"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/refine/filter_summaries",
                    "id": "#main/refine_filter_summaries"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#main/refine/reports",
                    "id": "#main/refine_reports"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/filter_report/saturation_txts",
                    "doc": "Transcript discovery saturation analysis",
                    "id": "#main/saturation_reports"
                },
                {
                    "type": "File",
                    "outputSource": "#main/skera/segmented_bam",
                    "id": "#main/segmented_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/skera/segmented_dataset",
                    "id": "#main/segmented_dataset"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/skera/summary_csv",
                    "id": "#main/segmented_summary"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/cluster/transcripts_bams",
                    "id": "#main/transcripts_bams"
                }
            ]
        },
        {
            "class": "CommandLineTool",
            "label": "Cluster FLNC reads and generate transcripts",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "ShellCommandRequirement"
                }
            ],
            "baseCommand": [
                "isoseq",
                "cluster2"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Input FLNC BAM, ConsensusReadSet XML, or FOFN",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#isoseq_cluster2.cwl/flnc_input"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file, instead of stderr",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#isoseq_cluster2.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Set log level (TRACE, DEBUG, INFO, WARN, FATAL)",
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#isoseq_cluster2.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "doc": "Output FLNCs that could not be clustered",
                    "inputBinding": {
                        "prefix": "--singletons"
                    },
                    "id": "#isoseq_cluster2.cwl/singletons"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "doc": "Number of sorting threads per BAM file. Defaults to -j",
                    "inputBinding": {
                        "valueFrom": "$(inputs.sort_threads !== null ? inputs.sort_threads : inputs.threads)",
                        "prefix": "--sort-threads"
                    },
                    "id": "#isoseq_cluster2.cwl/sort_threads"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "doc": "Number of threads to use, 0 means autodetection",
                    "inputBinding": {
                        "prefix": "-j"
                    },
                    "id": "#isoseq_cluster2.cwl/threads"
                },
                {
                    "type": "string",
                    "doc": "Output transcripts BAM",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#isoseq_cluster2.cwl/transcripts_bam"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Write annotated BAM file",
                    "inputBinding": {
                        "prefix": "--write-bam"
                    },
                    "id": "#isoseq_cluster2.cwl/write_bam"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Optional annotated BAM if --write-bam is used",
                    "outputBinding": {
                        "glob": "$(inputs.write_bam)"
                    },
                    "id": "#isoseq_cluster2.cwl/annotated_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "CSV report file",
                    "outputBinding": {
                        "glob": "*.cluster_report.csv"
                    },
                    "id": "#isoseq_cluster2.cwl/report_csv"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Optional singletons output if --singletons is used",
                    "outputBinding": {
                        "glob": "*.singletons.*"
                    },
                    "id": "#isoseq_cluster2.cwl/singletons_output"
                },
                {
                    "type": "File",
                    "doc": "Output transcripts BAM",
                    "outputBinding": {
                        "glob": "$(inputs.transcripts_bam)"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pbi",
                            "required": null
                        }
                    ],
                    "id": "#isoseq_cluster2.cwl/transcripts_output"
                }
            ],
            "id": "#isoseq_cluster2.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Iso-Seq collapse",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "isoseq",
                "collapse"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Alignments mapping Transcripts to reference genome",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#isoseq_collapse.cwl/alignments_bam"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "doc": "Do not collapse 5' shorter transcripts which miss one or multiple 5' exons to a longer transcript",
                    "inputBinding": {
                        "prefix": "--do-not-collapse-extra-5exons"
                    },
                    "id": "#isoseq_collapse.cwl/do_not_collapse_extra_5exons"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "FLNC BAM, optional input",
                    "inputBinding": {
                        "position": 2
                    },
                    "secondaryFiles": [
                        {
                            "required": false,
                            "pattern": ".pbi"
                        }
                    ],
                    "id": "#isoseq_collapse.cwl/flnc_bam"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file, instead of stderr",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#isoseq_collapse.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "doc": "Set log level",
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#isoseq_collapse.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 100,
                    "doc": "Maximum allowed 3' difference if on same exon",
                    "inputBinding": {
                        "prefix": "--max-3p-diff"
                    },
                    "id": "#isoseq_collapse.cwl/max_3p_diff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "doc": "Maximum allowed 5' difference if on same exon",
                    "inputBinding": {
                        "prefix": "--max-5p-diff"
                    },
                    "id": "#isoseq_collapse.cwl/max_5p_diff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 5,
                    "doc": "Ignore mismatches or indels shorter than or equal to N",
                    "inputBinding": {
                        "prefix": "--max-fuzzy-junction"
                    },
                    "id": "#isoseq_collapse.cwl/max_fuzzy_junction"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.99,
                    "doc": "Ignore alignments with less than minimum query read coverage",
                    "inputBinding": {
                        "prefix": "--min-aln-coverage"
                    },
                    "id": "#isoseq_collapse.cwl/min_aln_coverage"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.95,
                    "doc": "Ignore alignments with less than minimum alignment identity",
                    "inputBinding": {
                        "prefix": "--min-aln-identity"
                    },
                    "id": "#isoseq_collapse.cwl/min_aln_identity"
                },
                {
                    "type": "string",
                    "default": "collapse_isoforms.gff",
                    "doc": "Collapsed transcripts GFF",
                    "inputBinding": {
                        "position": 3
                    },
                    "id": "#isoseq_collapse.cwl/out_gff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "doc": "Number of threads to use, 0 means autodetection",
                    "inputBinding": {
                        "prefix": "-j"
                    },
                    "id": "#isoseq_collapse.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_gff.replace(/\\.gff$/, '.abundance.txt'))"
                    },
                    "id": "#isoseq_collapse.cwl/abundance_txt"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_gff.replace(/\\.gff$/, '.fasta'))"
                    },
                    "id": "#isoseq_collapse.cwl/collapse_fasta"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_gff)"
                    },
                    "id": "#isoseq_collapse.cwl/collapse_gff"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_gff.replace(/\\.gff$/, '.report.json'))"
                    },
                    "id": "#isoseq_collapse.cwl/collapse_report_json"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_gff.replace(/\\.gff$/, '.flnc_count.txt'))"
                    },
                    "id": "#isoseq_collapse.cwl/flnc_count_txt"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_gff.replace(/\\.gff$/, '.group.txt'))"
                    },
                    "id": "#isoseq_collapse.cwl/group_txt"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "${ return inputs.log_file ? inputs.log_file : []; }"
                    },
                    "id": "#isoseq_collapse.cwl/log_file_output"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_gff.replace(/\\.gff$/, '.read_stat.txt'))"
                    },
                    "id": "#isoseq_collapse.cwl/read_stat_txt"
                }
            ],
            "id": "#isoseq_collapse.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Iso-Seq refine full-length detection",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "isoseq",
                "refine"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Barcode/Primer FASTA or BarcodeSet XML",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#isoseq_refine.cwl/barcodes"
                },
                {
                    "type": "string",
                    "id": "#isoseq_refine.cwl/biosample_name"
                },
                {
                    "type": "File",
                    "doc": "Input dataset (ConsensusReadSet XML, FOFN, or BAM)",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#isoseq_refine.cwl/in_dataset"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#isoseq_refine.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "inputBinding": {
                        "prefix": "--require-polya"
                    },
                    "id": "#isoseq_refine.cwl/require_polya"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "inputBinding": {
                        "prefix": "-j"
                    },
                    "id": "#isoseq_refine.cwl/threads"
                }
            ],
            "arguments": [
                {
                    "position": 3,
                    "valueFrom": "$(\"flnc.\" + inputs.biosample_name + \".bam\")"
                }
            ],
            "stderr": "$(\"flnc.\" + inputs.biosample_name + \".refine.log\")",
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "flnc.$(inputs.biosample_name).filter_summary.report.json"
                    },
                    "id": "#isoseq_refine.cwl/filter_summary_json"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "flnc.$(inputs.biosample_name).bam"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pbi",
                            "required": null
                        }
                    ],
                    "id": "#isoseq_refine.cwl/out_flnc_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "flnc.$(inputs.biosample_name).report.csv"
                    },
                    "id": "#isoseq_refine.cwl/report_csv"
                }
            ],
            "id": "#isoseq_refine.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Primer detection and demultiplex (lima --isoseq)",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "ShellCommandRequirement"
                }
            ],
            "baseCommand": [
                "lima"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Barcode/Primer FASTA (e.g., IsoSeq_v2_primers_12.fasta)",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#lima_isoseq.cwl/barcodes"
                },
                {
                    "type": "boolean",
                    "default": true,
                    "doc": "Ignore <BioSamples> from XML input",
                    "inputBinding": {
                        "prefix": "--ignore-xml-biosamples"
                    },
                    "id": "#lima_isoseq.cwl/ignore_xml_biosamples"
                },
                {
                    "type": "File",
                    "doc": "Input dataset (ConsensusReadSet XML or BAM)",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#lima_isoseq.cwl/in_dataset"
                },
                {
                    "type": "boolean",
                    "default": true,
                    "inputBinding": {
                        "prefix": "--isoseq"
                    },
                    "id": "#lima_isoseq.cwl/isoseq_mode"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "lima-isoseq.log",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#lima_isoseq.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#lima_isoseq.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "fl",
                    "inputBinding": {
                        "position": 3,
                        "valueFrom": "$( self + \".consensusreadset.xml\" )"
                    },
                    "id": "#lima_isoseq.cwl/out_prefix"
                },
                {
                    "type": "boolean",
                    "default": true,
                    "doc": "In isoseq mode, overwrite existing sample names in the SM tag",
                    "inputBinding": {
                        "prefix": "--overwrite-biosample-names"
                    },
                    "id": "#lima_isoseq.cwl/overwrite_biosample_names"
                },
                {
                    "type": "boolean",
                    "default": true,
                    "inputBinding": {
                        "prefix": "--peek-guess"
                    },
                    "id": "#lima_isoseq.cwl/peek_guess"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "inputBinding": {
                        "prefix": "-j"
                    },
                    "id": "#lima_isoseq.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": [
                            "$(inputs.out_prefix).lima.counts"
                        ]
                    },
                    "id": "#lima_isoseq.cwl/counts"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "doc": "PacBio BAM index files corresponding to demultiplexed BAMs (patterns like <out_prefix>*.bam.pbi)",
                    "outputBinding": {
                        "glob": [
                            "$(inputs.out_prefix)*.bam.pbi"
                        ]
                    },
                    "id": "#lima_isoseq.cwl/demux_bam_pbis"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Demultiplexed BAM files produced by lima (patterns like <out_prefix>*.bam)",
                    "outputBinding": {
                        "glob": [
                            "$(inputs.out_prefix)*.bam"
                        ]
                    },
                    "id": "#lima_isoseq.cwl/demux_bams"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Log file from lima execution",
                    "outputBinding": {
                        "glob": "$(inputs.log_file)"
                    },
                    "id": "#lima_isoseq.cwl/lima_log"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).consensusreadset.xml"
                    },
                    "id": "#lima_isoseq.cwl/out_dataset"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": [
                            "$(inputs.out_prefix).lima.report"
                        ]
                    },
                    "id": "#lima_isoseq.cwl/report"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": [
                            "$(inputs.out_prefix).lima.summary"
                        ]
                    },
                    "id": "#lima_isoseq.cwl/summary"
                }
            ],
            "id": "#lima_isoseq.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "pbmm2 align (ISOSEQ preset)",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "ShellCommandRequirement"
                }
            ],
            "baseCommand": [
                "pbmm2",
                "align"
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "BAM index type for sorted output (NONE, BAI, CSI)",
                    "inputBinding": {
                        "prefix": "--bam-index"
                    },
                    "id": "#pbmm2_align.cwl/bam_index"
                },
                {
                    "type": "File",
                    "doc": "Input FLNC BAM (from isoseq refine/cluster2)",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#pbmm2_align.cwl/in_bam"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#pbmm2_align.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#pbmm2_align.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 95.0,
                    "doc": "Minimum gap-compressed sequence identity in percent",
                    "inputBinding": {
                        "prefix": "--min-gap-comp-id-perc"
                    },
                    "id": "#pbmm2_align.cwl/min_gap_comp_id_perc"
                },
                {
                    "type": "string",
                    "default": "mapped.bam",
                    "doc": "Output aligned BAM",
                    "inputBinding": {
                        "position": 3
                    },
                    "id": "#pbmm2_align.cwl/out_bam"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "ISOSEQ",
                    "inputBinding": {
                        "prefix": "--preset"
                    },
                    "id": "#pbmm2_align.cwl/preset"
                },
                {
                    "type": "File",
                    "doc": "Reference FASTA, ReferenceSet XML, or prebuilt .mmi index",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#pbmm2_align.cwl/reference"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "inputBinding": {
                        "prefix": "--sort"
                    },
                    "id": "#pbmm2_align.cwl/sort"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "inputBinding": {
                        "prefix": "-j"
                    },
                    "id": "#pbmm2_align.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.log_file)"
                    },
                    "id": "#pbmm2_align.cwl/log_file_output"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_bam)"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".bai",
                            "required": false
                        }
                    ],
                    "id": "#pbmm2_align.cwl/mapped_bam"
                }
            ],
            "id": "#pbmm2_align.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Pigeon classify - Transcript classification",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "pigeon",
                "classify"
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Reference annotation GTF with .pgi index",
                    "inputBinding": {
                        "position": 2
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pgi",
                            "required": null
                        }
                    ],
                    "id": "#pigeon_classify.cwl/annotation_gtf"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "IsoSeq FL count info from isoseq collapse (*.flnc_counts.txt)",
                    "inputBinding": {
                        "prefix": "--flnc"
                    },
                    "id": "#pigeon_classify.cwl/flnc_count"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Isoforms to classify (from isoseq collapse)",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#pigeon_classify.cwl/isoforms_gff"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file, instead of stderr",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#pigeon_classify.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "doc": "Set log level",
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#pigeon_classify.cwl/log_level"
                },
                {
                    "type": "string",
                    "default": ".",
                    "doc": "Destination directory for all output files",
                    "inputBinding": {
                        "prefix": "--out-dir"
                    },
                    "id": "#pigeon_classify.cwl/out_dir"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Prefix for all output files",
                    "inputBinding": {
                        "prefix": "--out-prefix"
                    },
                    "id": "#pigeon_classify.cwl/out_prefix"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Reference FASTA with .fai index",
                    "inputBinding": {
                        "position": 3
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".fai",
                            "required": null
                        }
                    ],
                    "id": "#pigeon_classify.cwl/reference_fa"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "doc": "Number of threads to use, 0 means autodetection",
                    "inputBinding": {
                        "prefix": "-j"
                    },
                    "id": "#pigeon_classify.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix)_classification.txt"
                    },
                    "id": "#pigeon_classify.cwl/classification_txt"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix)_junctions.txt"
                    },
                    "id": "#pigeon_classify.cwl/junctions_txt"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "${ return inputs.log_file ? inputs.log_file : []; }"
                    },
                    "id": "#pigeon_classify.cwl/log_file_output"
                },
                {
                    "type": "File",
                    "doc": "JSON report file with detailed classification statistics",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).report.json"
                    },
                    "id": "#pigeon_classify.cwl/report_json"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).summary.txt"
                    },
                    "id": "#pigeon_classify.cwl/summary_txt"
                }
            ],
            "id": "#pigeon_classify.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Pigeon filter - Transcript classification filtering",
            "doc": "Filter transcript classifications based on various quality criteria including\npoly-A detection, junction coverage, and distance to annotated 3' ends.\n",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "listing": [
                        "$(inputs.classification_txt)",
                        "$(inputs.junctions_txt)",
                        "${ if (inputs.isoforms_gff) { return inputs.isoforms_gff; } else { return null; } }"
                    ],
                    "class": "InitialWorkDirRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "pigeon",
                "filter"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Classifications to filter",
                    "inputBinding": {
                        "position": 1,
                        "valueFrom": "$(self.basename)"
                    },
                    "id": "#pigeon_filter.cwl/classification_txt"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Isoforms GFF file to be filtered (produces sorted.filtered_lite.gff output)",
                    "inputBinding": {
                        "prefix": "--isoforms",
                        "valueFrom": "$(self.basename)"
                    },
                    "id": "#pigeon_filter.cwl/isoforms_gff"
                },
                {
                    "type": "File",
                    "doc": "Junctions file (companion to classification file, must be in same directory)",
                    "id": "#pigeon_filter.cwl/junctions_txt"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file, instead of stderr",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#pigeon_filter.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "doc": "Set log level",
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#pigeon_filter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "doc": "Maximum distance to an annotated 3' end to preserve as a valid 3' end",
                    "inputBinding": {
                        "prefix": "--max-distance"
                    },
                    "id": "#pigeon_filter.cwl/max_distance"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 3,
                    "doc": "Minimum junction coverage for each isoform",
                    "inputBinding": {
                        "prefix": "--min-cov"
                    },
                    "id": "#pigeon_filter.cwl/min_cov"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "doc": "Filter out all mono-exonic transcripts",
                    "inputBinding": {
                        "prefix": "--mono-exon"
                    },
                    "id": "#pigeon_filter.cwl/mono_exon"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.6,
                    "doc": "Adenine percentage at genomic 3' end to flag an isoform as intra-priming",
                    "inputBinding": {
                        "prefix": "--polya-percent"
                    },
                    "id": "#pigeon_filter.cwl/polya_percent"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 6,
                    "doc": "Continuous run-A length at genomic 3' end to flag an isoform as intra-priming",
                    "inputBinding": {
                        "prefix": "--polya-run-length"
                    },
                    "id": "#pigeon_filter.cwl/polya_run_length"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "doc": "Skip junctions.txt filtering",
                    "inputBinding": {
                        "prefix": "--skip-junctions"
                    },
                    "id": "#pigeon_filter.cwl/skip_junctions"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "doc": "Number of threads to use, 0 means autodetection",
                    "inputBinding": {
                        "prefix": "--num-threads"
                    },
                    "id": "#pigeon_filter.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "doc": "Filtered classification file",
                    "outputBinding": {
                        "glob": "*.filtered_lite_classification.txt"
                    },
                    "id": "#pigeon_filter.cwl/filtered_classification_txt"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Filtered isoforms GFF (only if --isoforms is used)",
                    "outputBinding": {
                        "glob": "*.sorted.filtered_lite.gff"
                    },
                    "id": "#pigeon_filter.cwl/filtered_gff"
                },
                {
                    "type": "File",
                    "doc": "Filtered junctions file",
                    "outputBinding": {
                        "glob": "*.filtered_lite_junctions.txt"
                    },
                    "id": "#pigeon_filter.cwl/filtered_junctions_txt"
                },
                {
                    "type": "File",
                    "doc": "Reasons for filtering each isoform",
                    "outputBinding": {
                        "glob": "*.filtered_lite_reasons.txt"
                    },
                    "id": "#pigeon_filter.cwl/filtered_reasons_txt"
                },
                {
                    "type": "File",
                    "doc": "Filtered classification report (JSON format)",
                    "outputBinding": {
                        "glob": "*.filtered.report.json"
                    },
                    "id": "#pigeon_filter.cwl/filtered_report_json"
                },
                {
                    "type": "File",
                    "doc": "Filtered classification summary",
                    "outputBinding": {
                        "glob": "*.filtered.summary.txt"
                    },
                    "id": "#pigeon_filter.cwl/filtered_summary_txt"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "${ return inputs.log_file ? inputs.log_file : []; }"
                    },
                    "id": "#pigeon_filter.cwl/log_file_output"
                }
            ],
            "id": "#pigeon_filter.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Pigeon prepare - Prepare classification input files",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "listing": "$(inputs.input_files)",
                    "class": "InitialWorkDirRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "pigeon",
                "prepare"
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Input file(s) for pigeon classify. These include reference annotations GTF/GFF, reference sequence FASTA, and any supplemental data in BED/TSV formats.\n",
                    "inputBinding": {
                        "position": 1,
                        "valueFrom": "${return self.map(function(f) { return f.basename; });}\n"
                    },
                    "id": "#pigeon_prepare.cwl/input_files"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file, instead of stderr",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#pigeon_prepare.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "doc": "Set log level",
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#pigeon_prepare.cwl/log_level"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "${ return inputs.log_file ? inputs.log_file : []; }"
                    },
                    "id": "#pigeon_prepare.cwl/log_file_output"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Prepared annotation GTF file with .pgi index (only when GTF input is provided)",
                    "outputBinding": {
                        "glob": "*.sorted.gtf"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pgi",
                            "required": null
                        }
                    ],
                    "id": "#pigeon_prepare.cwl/prepared_annotation"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Prepared isoforms GFF file with .pgi index (only when GFF input is provided)",
                    "outputBinding": {
                        "glob": "*.sorted.gff"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pgi",
                            "required": null
                        }
                    ],
                    "id": "#pigeon_prepare.cwl/prepared_isoforms"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "Reference FASTA with .fai index (only when FASTA input is provided)",
                    "outputBinding": {
                        "glob": "${\n  // Find the FASTA file from input_files and return its basename\n  for (var i = 0; i < inputs.input_files.length; i++) {\n    var fname = inputs.input_files[i].basename;\n    if (fname.endsWith('.fa') || fname.endsWith('.fasta')) {\n      return fname;\n    }\n  }\n  return null;\n}\n"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".fai",
                            "required": null
                        }
                    ],
                    "id": "#pigeon_prepare.cwl/prepared_reference"
                }
            ],
            "id": "#pigeon_prepare.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Pigeon report - Transcript reporting",
            "doc": "Generate transcript reporting with subsampling analysis to assess \nsaturation and diversity of the isoform dataset.\n",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "baseCommand": [
                "pigeon",
                "report"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Classification file (typically the filtered classification file)",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#pigeon_report.cwl/classification_txt"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "doc": "Only count isoforms with > 1 supporting read",
                    "inputBinding": {
                        "prefix": "--exclude-singletons"
                    },
                    "id": "#pigeon_report.cwl/exclude_singletons"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file, instead of stderr",
                    "inputBinding": {
                        "prefix": "--log-file"
                    },
                    "id": "#pigeon_report.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "doc": "Set log level",
                    "inputBinding": {
                        "prefix": "--log-level"
                    },
                    "id": "#pigeon_report.cwl/log_level"
                },
                {
                    "type": "string",
                    "default": "saturation.txt",
                    "doc": "Output filename for subsampling report",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#pigeon_report.cwl/output_filename"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "doc": "Number of reads between subsampling datapoints, 0 means auto-determined",
                    "inputBinding": {
                        "prefix": "--sub-sample-increment"
                    },
                    "id": "#pigeon_report.cwl/sub_sample_increment"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "doc": "Number of threads to use, 0 means autodetection",
                    "inputBinding": {
                        "prefix": "--num-threads"
                    },
                    "id": "#pigeon_report.cwl/threads"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "${ return inputs.log_file ? inputs.log_file : []; }"
                    },
                    "id": "#pigeon_report.cwl/log_file_output"
                },
                {
                    "type": "File",
                    "doc": "Saturation/subsampling report file",
                    "outputBinding": {
                        "glob": "$(inputs.output_filename)"
                    },
                    "id": "#pigeon_report.cwl/saturation_txt"
                }
            ],
            "id": "#pigeon_report.cwl"
        },
        {
            "class": "CommandLineTool",
            "label": "Kinnex segmentation (skera split)",
            "requirements": [
                {
                    "dockerPull": "pgc-images.sbgenomics.com/childrens-bti/kinnex_longreads:v1.0",
                    "class": "DockerRequirement"
                },
                {
                    "listing": [
                        {
                            "entryname": "run_skera.sh",
                            "entry": "#!/usr/bin/env bash\nset -euo pipefail\nINPUT=$1\nADAPTERS=$2\nPREFIX=$3\nTHREADS=$4\n# CWL may omit boolean false and other optional args\nOUTPUT_XML_FLAG=\"true\"  # true|false -> choose .xml vs .bam\nLOG_LEVEL=\"\"\nLOG_FILE=\"\"\nif [ \"$#\" -ge 5 ]; then OUTPUT_XML_FLAG=\"$5\"; fi\nif [ \"$#\" -ge 6 ]; then LOG_LEVEL=\"$6\"; fi\nif [ \"$#\" -ge 7 ]; then LOG_FILE=\"$7\"; fi\n\necho \"skera split\" >&2\necho \"input: $INPUT\" >&2\necho \"adapters: $ADAPTERS\" >&2\necho \"prefix: $PREFIX\" >&2\necho \"threads: $THREADS\" >&2\necho \"output_xml: $OUTPUT_XML_FLAG\" >&2\nif [[ -n \"$LOG_LEVEL\" ]]; then echo \"log-level: $LOG_LEVEL\" >&2; fi\nif [[ -n \"$LOG_FILE\" ]]; then echo \"log-file: $LOG_FILE\" >&2; fi\n\n# Build options per 'skera split -h'\nOPTS=\"split -j $THREADS\"\nif [[ -n \"$LOG_LEVEL\" ]]; then\n  OPTS=\"$OPTS --log-level $LOG_LEVEL\"\nfi\n# Always write a log file in the working directory for CWL to collect\nif [[ -z \"$LOG_FILE\" ]]; then\n  LOG_FILE=\"skera.log\"\nfi\nOPTS=\"$OPTS --log-file $LOG_FILE\"\n\nif [[ \"$OUTPUT_XML_FLAG\" == \"true\" ]]; then\n  OUT=\"$PREFIX.consensusreadset.xml\"\nelse\n  OUT=\"$PREFIX.bam\"\nfi\n\necho \"+ skera $OPTS \\\"$INPUT\\\" \\\"$ADAPTERS\\\" \\\"$OUT\\\"\" >&2\n# shellcheck disable=SC2086\nskera $OPTS \"$INPUT\" \"$ADAPTERS\" \"$OUT\"\n\n\necho \"Outputs after skera run:\" >&2\nls -la >&2\n"
                        }
                    ],
                    "class": "InitialWorkDirRequirement"
                },
                {
                    "class": "ShellCommandRequirement"
                }
            ],
            "baseCommand": [
                "bash",
                "run_skera.sh"
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Adapters FASTA or AdapterSet XML (per skera split)",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#skera_split.cwl/adapters_fa"
                },
                {
                    "type": "File",
                    "doc": "Input dataset (BAM or ConsensusReadSet XML)",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#skera_split.cwl/in_bam"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Log to a file instead of stderr (path)",
                    "inputBinding": {
                        "position": 7
                    },
                    "id": "#skera_split.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "Set log level (TRACE, DEBUG, INFO, WARN, FATAL)",
                    "inputBinding": {
                        "position": 6
                    },
                    "id": "#skera_split.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "segmented",
                    "inputBinding": {
                        "position": 3
                    },
                    "id": "#skera_split.cwl/out_prefix"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "inputBinding": {
                        "position": 4
                    },
                    "id": "#skera_split.cwl/threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "doc": "When true, write PREFIX.consensusreadset.xml (else PREFIX.bam)",
                    "inputBinding": {
                        "position": 5,
                        "valueFrom": "$(self ? 'true' : 'false')\n"
                    },
                    "id": "#skera_split.cwl/use_dataset_xml"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).found_adapters.csv.gz"
                    },
                    "id": "#skera_split.cwl/adapters_csv_gz"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).ligations.csv"
                    },
                    "id": "#skera_split.cwl/ligations_csv"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).non_passing.bam"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pbi",
                            "required": null
                        }
                    ],
                    "id": "#skera_split.cwl/non_passing_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).read_lengths.csv"
                    },
                    "id": "#skera_split.cwl/read_lengths_csv"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).bam"
                    },
                    "secondaryFiles": [
                        {
                            "pattern": ".pbi",
                            "required": null
                        }
                    ],
                    "id": "#skera_split.cwl/segmented_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "doc": "ConsensusReadSet XML (only created when use_dataset_xml=true and may not be output by skera)",
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).consensusreadset.xml"
                    },
                    "id": "#skera_split.cwl/segmented_dataset"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.out_prefix).summary.csv"
                    },
                    "id": "#skera_split.cwl/summary_csv"
                }
            ],
            "id": "#skera_split.cwl"
        },
        {
            "class": "Workflow",
            "label": "Scatter isoseq cluster2 across multiple FLNC BAMs",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#isoseq_cluster2_scatter.cwl/flnc_bams"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "INFO",
                    "id": "#isoseq_cluster2_scatter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#isoseq_cluster2_scatter.cwl/singletons"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#isoseq_cluster2_scatter.cwl/threads"
                }
            ],
            "steps": [
                {
                    "run": "#isoseq_cluster2.cwl",
                    "in": [
                        {
                            "source": "#isoseq_cluster2_scatter.cwl/flnc_bams",
                            "id": "#isoseq_cluster2_scatter.cwl/cluster_each/flnc_input"
                        },
                        {
                            "valueFrom": "$(\"clustered.\" + inputs.flnc_input.basename.replace(/^flnc\\./,'').replace(/\\.bam$/,'') + \".isoseq-cluster2.log\")",
                            "id": "#isoseq_cluster2_scatter.cwl/cluster_each/log_file"
                        },
                        {
                            "source": "#isoseq_cluster2_scatter.cwl/log_level",
                            "id": "#isoseq_cluster2_scatter.cwl/cluster_each/log_level"
                        },
                        {
                            "source": "#isoseq_cluster2_scatter.cwl/singletons",
                            "id": "#isoseq_cluster2_scatter.cwl/cluster_each/singletons"
                        },
                        {
                            "source": "#isoseq_cluster2_scatter.cwl/threads",
                            "id": "#isoseq_cluster2_scatter.cwl/cluster_each/threads"
                        },
                        {
                            "valueFrom": "$(\"clustered.\" + inputs.flnc_input.basename.replace(/^flnc\\./,'').replace(/\\.bam$/,'') + \".transcripts.bam\")",
                            "id": "#isoseq_cluster2_scatter.cwl/cluster_each/transcripts_bam"
                        }
                    ],
                    "out": [
                        "#isoseq_cluster2_scatter.cwl/cluster_each/transcripts_output",
                        "#isoseq_cluster2_scatter.cwl/cluster_each/singletons_output",
                        "#isoseq_cluster2_scatter.cwl/cluster_each/annotated_bam",
                        "#isoseq_cluster2_scatter.cwl/cluster_each/report_csv"
                    ],
                    "scatter": "#isoseq_cluster2_scatter.cwl/cluster_each/flnc_input",
                    "scatterMethod": "dotproduct",
                    "id": "#isoseq_cluster2_scatter.cwl/cluster_each"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_cluster2_scatter.cwl/cluster_each/annotated_bam",
                    "id": "#isoseq_cluster2_scatter.cwl/annotated_bams"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_cluster2_scatter.cwl/cluster_each/report_csv",
                    "id": "#isoseq_cluster2_scatter.cwl/report_csvs"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_cluster2_scatter.cwl/cluster_each/singletons_output",
                    "id": "#isoseq_cluster2_scatter.cwl/singletons_outputs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#isoseq_cluster2_scatter.cwl/cluster_each/transcripts_output",
                    "id": "#isoseq_cluster2_scatter.cwl/transcripts_bams"
                }
            ],
            "id": "#isoseq_cluster2_scatter.cwl"
        },
        {
            "class": "Workflow",
            "label": "Scatter isoseq collapse across multiple aligned BAMs",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#isoseq_collapse_scatter.cwl/aligned_bams"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#isoseq_collapse_scatter.cwl/do_not_collapse_extra_5exons"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#isoseq_collapse_scatter.cwl/flnc_bams"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "id": "#isoseq_collapse_scatter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 100,
                    "id": "#isoseq_collapse_scatter.cwl/max_3p_diff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "id": "#isoseq_collapse_scatter.cwl/max_5p_diff"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 5,
                    "id": "#isoseq_collapse_scatter.cwl/max_fuzzy_junction"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.99,
                    "id": "#isoseq_collapse_scatter.cwl/min_aln_coverage"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.95,
                    "id": "#isoseq_collapse_scatter.cwl/min_aln_identity"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#isoseq_collapse_scatter.cwl/threads"
                }
            ],
            "steps": [
                {
                    "run": "#isoseq_collapse.cwl",
                    "in": [
                        {
                            "source": "#isoseq_collapse_scatter.cwl/aligned_bams",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/alignments_bam"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/do_not_collapse_extra_5exons",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/do_not_collapse_extra_5exons"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/flnc_bams",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/flnc_bam"
                        },
                        {
                            "valueFrom": "$(\"collapse_isoforms.\" + inputs.alignments_bam.basename.replace(/\\.transcripts\\.bam$/, '').replace(/^mapped\\.clustered\\./, '') + \".log\")",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/log_file"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/log_level",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/log_level"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/max_3p_diff",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/max_3p_diff"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/max_5p_diff",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/max_5p_diff"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/max_fuzzy_junction",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/max_fuzzy_junction"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/min_aln_coverage",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/min_aln_coverage"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/min_aln_identity",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/min_aln_identity"
                        },
                        {
                            "valueFrom": "$(\"collapse_isoforms.\" + inputs.alignments_bam.basename.replace(/\\.transcripts\\.bam$/, '').replace(/^mapped\\.clustered\\./, '') + \".gff\")",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/out_gff"
                        },
                        {
                            "source": "#isoseq_collapse_scatter.cwl/threads",
                            "id": "#isoseq_collapse_scatter.cwl/collapse_each/threads"
                        }
                    ],
                    "out": [
                        "#isoseq_collapse_scatter.cwl/collapse_each/collapse_gff",
                        "#isoseq_collapse_scatter.cwl/collapse_each/collapse_fasta",
                        "#isoseq_collapse_scatter.cwl/collapse_each/group_txt",
                        "#isoseq_collapse_scatter.cwl/collapse_each/flnc_count_txt",
                        "#isoseq_collapse_scatter.cwl/collapse_each/read_stat_txt",
                        "#isoseq_collapse_scatter.cwl/collapse_each/collapse_report_json",
                        "#isoseq_collapse_scatter.cwl/collapse_each/abundance_txt"
                    ],
                    "scatter": [
                        "#isoseq_collapse_scatter.cwl/collapse_each/alignments_bam",
                        "#isoseq_collapse_scatter.cwl/collapse_each/flnc_bam"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#isoseq_collapse_scatter.cwl/collapse_each"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/abundance_txt",
                    "id": "#isoseq_collapse_scatter.cwl/abundance_txts"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/collapse_fasta",
                    "id": "#isoseq_collapse_scatter.cwl/collapse_fastas"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/collapse_gff",
                    "id": "#isoseq_collapse_scatter.cwl/collapse_gffs"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/collapse_report_json",
                    "id": "#isoseq_collapse_scatter.cwl/collapse_report_jsons"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/flnc_count_txt",
                    "id": "#isoseq_collapse_scatter.cwl/flnc_count_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/group_txt",
                    "id": "#isoseq_collapse_scatter.cwl/group_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#isoseq_collapse_scatter.cwl/collapse_each/read_stat_txt",
                    "id": "#isoseq_collapse_scatter.cwl/read_stat_txts"
                }
            ],
            "id": "#isoseq_collapse_scatter.cwl"
        },
        {
            "class": "Workflow",
            "label": "Scatter isoseq refine across demultiplexed BAMs",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "id": "#isoseq_refine_scatter.cwl/barcodes"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#isoseq_refine_scatter.cwl/demux_bams"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "INFO",
                    "id": "#isoseq_refine_scatter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#isoseq_refine_scatter.cwl/require_polya"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#isoseq_refine_scatter.cwl/threads"
                }
            ],
            "steps": [
                {
                    "run": "#isoseq_refine.cwl",
                    "in": [
                        {
                            "source": "#isoseq_refine_scatter.cwl/barcodes",
                            "id": "#isoseq_refine_scatter.cwl/refine_each/barcodes"
                        },
                        {
                            "valueFrom": "$(inputs.in_dataset.nameroot.replace(/^fl\\./,''))",
                            "id": "#isoseq_refine_scatter.cwl/refine_each/biosample_name"
                        },
                        {
                            "source": "#isoseq_refine_scatter.cwl/demux_bams",
                            "id": "#isoseq_refine_scatter.cwl/refine_each/in_dataset"
                        },
                        {
                            "source": "#isoseq_refine_scatter.cwl/log_level",
                            "id": "#isoseq_refine_scatter.cwl/refine_each/log_level"
                        },
                        {
                            "source": "#isoseq_refine_scatter.cwl/require_polya",
                            "id": "#isoseq_refine_scatter.cwl/refine_each/require_polya"
                        },
                        {
                            "source": "#isoseq_refine_scatter.cwl/threads",
                            "id": "#isoseq_refine_scatter.cwl/refine_each/threads"
                        }
                    ],
                    "scatter": "#isoseq_refine_scatter.cwl/refine_each/in_dataset",
                    "out": [
                        "#isoseq_refine_scatter.cwl/refine_each/out_flnc_bam",
                        "#isoseq_refine_scatter.cwl/refine_each/filter_summary_json",
                        "#isoseq_refine_scatter.cwl/refine_each/report_csv"
                    ],
                    "id": "#isoseq_refine_scatter.cwl/refine_each"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_refine_scatter.cwl/refine_each/filter_summary_json",
                    "id": "#isoseq_refine_scatter.cwl/filter_summaries"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#isoseq_refine_scatter.cwl/refine_each/out_flnc_bam",
                    "id": "#isoseq_refine_scatter.cwl/out_flnc_bams"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#isoseq_refine_scatter.cwl/refine_each/report_csv",
                    "id": "#isoseq_refine_scatter.cwl/reports"
                }
            ],
            "id": "#isoseq_refine_scatter.cwl"
        },
        {
            "class": "Workflow",
            "label": "Run lima --isoseq on segmented dataset",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "id": "#lima_isoseq_run.cwl/barcodes"
                },
                {
                    "type": "File",
                    "id": "#lima_isoseq_run.cwl/in_dataset"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "lima-isoseq.log",
                    "id": "#lima_isoseq_run.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "INFO",
                    "id": "#lima_isoseq_run.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "fl",
                    "id": "#lima_isoseq_run.cwl/out_prefix"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#lima_isoseq_run.cwl/threads"
                }
            ],
            "steps": [
                {
                    "run": "#lima_isoseq.cwl",
                    "in": [
                        {
                            "source": "#lima_isoseq_run.cwl/barcodes",
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/barcodes"
                        },
                        {
                            "default": true,
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/ignore_xml_biosamples"
                        },
                        {
                            "source": "#lima_isoseq_run.cwl/in_dataset",
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/in_dataset"
                        },
                        {
                            "default": true,
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/isoseq_mode"
                        },
                        {
                            "source": "#lima_isoseq_run.cwl/log_file",
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/log_file"
                        },
                        {
                            "source": "#lima_isoseq_run.cwl/log_level",
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/log_level"
                        },
                        {
                            "source": "#lima_isoseq_run.cwl/out_prefix",
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/out_prefix"
                        },
                        {
                            "default": true,
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/overwrite_biosample_names"
                        },
                        {
                            "default": true,
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/peek_guess"
                        },
                        {
                            "source": "#lima_isoseq_run.cwl/threads",
                            "id": "#lima_isoseq_run.cwl/lima_isoseq/threads"
                        }
                    ],
                    "out": [
                        "#lima_isoseq_run.cwl/lima_isoseq/out_dataset",
                        "#lima_isoseq_run.cwl/lima_isoseq/demux_bams",
                        "#lima_isoseq_run.cwl/lima_isoseq/demux_bam_pbis",
                        "#lima_isoseq_run.cwl/lima_isoseq/counts",
                        "#lima_isoseq_run.cwl/lima_isoseq/report",
                        "#lima_isoseq_run.cwl/lima_isoseq/summary",
                        "#lima_isoseq_run.cwl/lima_isoseq/lima_log"
                    ],
                    "id": "#lima_isoseq_run.cwl/lima_isoseq"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/counts",
                    "id": "#lima_isoseq_run.cwl/counts"
                },
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/demux_bam_pbis",
                    "id": "#lima_isoseq_run.cwl/demux_bam_pbis"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/demux_bams",
                    "id": "#lima_isoseq_run.cwl/demux_bams"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/lima_log",
                    "id": "#lima_isoseq_run.cwl/lima_log"
                },
                {
                    "type": "File",
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/out_dataset",
                    "id": "#lima_isoseq_run.cwl/out_dataset"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/report",
                    "id": "#lima_isoseq_run.cwl/report"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#lima_isoseq_run.cwl/lima_isoseq/summary",
                    "id": "#lima_isoseq_run.cwl/summary"
                }
            ],
            "id": "#lima_isoseq_run.cwl"
        },
        {
            "class": "Workflow",
            "label": "Scatter pbmm2 align (ISOSEQ preset) across multiple BAMs",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "doc": "BAM index type for sorted output (NONE, BAI, CSI)",
                    "id": "#pbmm2_align_scatter.cwl/bam_index"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "INFO",
                    "id": "#pbmm2_align_scatter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 95.0,
                    "id": "#pbmm2_align_scatter.cwl/min_gap_comp_id_perc"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "ISOSEQ",
                    "id": "#pbmm2_align_scatter.cwl/preset"
                },
                {
                    "type": "File",
                    "id": "#pbmm2_align_scatter.cwl/reference"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#pbmm2_align_scatter.cwl/sort"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#pbmm2_align_scatter.cwl/threads"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#pbmm2_align_scatter.cwl/transcript_bams"
                }
            ],
            "steps": [
                {
                    "run": "#pbmm2_align.cwl",
                    "in": [
                        {
                            "source": "#pbmm2_align_scatter.cwl/bam_index",
                            "id": "#pbmm2_align_scatter.cwl/align_each/bam_index"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/transcript_bams",
                            "id": "#pbmm2_align_scatter.cwl/align_each/in_bam"
                        },
                        {
                            "valueFrom": "$(\"pbmm2.align.\" + inputs.in_bam.basename.replace(/\\.bam$/,'') + \".log\")",
                            "id": "#pbmm2_align_scatter.cwl/align_each/log_file"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/log_level",
                            "id": "#pbmm2_align_scatter.cwl/align_each/log_level"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/min_gap_comp_id_perc",
                            "id": "#pbmm2_align_scatter.cwl/align_each/min_gap_comp_id_perc"
                        },
                        {
                            "valueFrom": "$(\"mapped.\" + inputs.in_bam.basename.replace(/\\.bam$/,'') + \".bam\")",
                            "id": "#pbmm2_align_scatter.cwl/align_each/out_bam"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/preset",
                            "id": "#pbmm2_align_scatter.cwl/align_each/preset"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/reference",
                            "id": "#pbmm2_align_scatter.cwl/align_each/reference"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/sort",
                            "id": "#pbmm2_align_scatter.cwl/align_each/sort"
                        },
                        {
                            "source": "#pbmm2_align_scatter.cwl/threads",
                            "id": "#pbmm2_align_scatter.cwl/align_each/threads"
                        }
                    ],
                    "out": [
                        "#pbmm2_align_scatter.cwl/align_each/mapped_bam",
                        "#pbmm2_align_scatter.cwl/align_each/log_file_output"
                    ],
                    "scatter": "#pbmm2_align_scatter.cwl/align_each/in_bam",
                    "scatterMethod": "dotproduct",
                    "id": "#pbmm2_align_scatter.cwl/align_each"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": "File"
                        }
                    ],
                    "outputSource": "#pbmm2_align_scatter.cwl/align_each/log_file_output",
                    "id": "#pbmm2_align_scatter.cwl/log_files"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pbmm2_align_scatter.cwl/align_each/mapped_bam",
                    "id": "#pbmm2_align_scatter.cwl/mapped_bams"
                }
            ],
            "id": "#pbmm2_align_scatter.cwl"
        },
        {
            "class": "Workflow",
            "label": "Scatter pigeon prepare+classify across multiple collapsed GFF files",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "MultipleInputFeatureRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Reference annotation GTF file (will be prepared by pigeon prepare)",
                    "id": "#pigeon_classify_scatter.cwl/annotation_gtf"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Array of collapse GFF files",
                    "id": "#pigeon_classify_scatter.cwl/collapse_gffs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Array of FLNC count files (*.flnc_count.txt) from isoseq collapse",
                    "id": "#pigeon_classify_scatter.cwl/flnc_counts"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "id": "#pigeon_classify_scatter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "pigeon",
                    "id": "#pigeon_classify_scatter.cwl/out_prefix_base"
                },
                {
                    "type": "File",
                    "doc": "Reference FASTA file (will be prepared by pigeon prepare)",
                    "id": "#pigeon_classify_scatter.cwl/reference_fa"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#pigeon_classify_scatter.cwl/threads"
                }
            ],
            "steps": [
                {
                    "run": "#pigeon_classify.cwl",
                    "in": [
                        {
                            "source": "#pigeon_classify_scatter.cwl/prepare_references/prepared_annotation",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/annotation_gtf"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/flnc_counts",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/flnc_count"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/prepare_isoforms/prepared_isoforms",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/isoforms_gff"
                        },
                        {
                            "valueFrom": "${\n  var prefix_base = inputs.out_prefix_base || \"pigeon\";\n  var basename = inputs.isoforms_gff.basename;\n  var sample = basename.replace(/^collapse_isoforms\\./, '').replace(/\\.sorted\\.gff$/, '').replace(/\\.gff$/, '');\n  return prefix_base + \"_classify_\" + sample + \".log\";\n}\n",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/log_file"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/log_level",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/log_level"
                        },
                        {
                            "valueFrom": "${\n  var prefix_base = inputs.out_prefix_base || \"pigeon\";\n  var basename = inputs.isoforms_gff.basename;\n  var sample = basename.replace(/^collapse_isoforms\\./, '').replace(/\\.sorted\\.gff$/, '').replace(/\\.gff$/, '');\n  return prefix_base + \".\" + sample;\n}\n",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/out_prefix"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/out_prefix_base",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/out_prefix_base"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/prepare_references/prepared_reference",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/reference_fa"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/threads",
                            "id": "#pigeon_classify_scatter.cwl/classify_each/threads"
                        }
                    ],
                    "out": [
                        "#pigeon_classify_scatter.cwl/classify_each/classification_txt",
                        "#pigeon_classify_scatter.cwl/classify_each/junctions_txt",
                        "#pigeon_classify_scatter.cwl/classify_each/report_json",
                        "#pigeon_classify_scatter.cwl/classify_each/summary_txt"
                    ],
                    "scatter": [
                        "#pigeon_classify_scatter.cwl/classify_each/isoforms_gff",
                        "#pigeon_classify_scatter.cwl/classify_each/flnc_count"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#pigeon_classify_scatter.cwl/classify_each"
                },
                {
                    "run": "#pigeon_prepare.cwl",
                    "in": [
                        {
                            "source": "#pigeon_classify_scatter.cwl/collapse_gffs",
                            "valueFrom": "$([self])",
                            "id": "#pigeon_classify_scatter.cwl/prepare_isoforms/input_files"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/log_level",
                            "id": "#pigeon_classify_scatter.cwl/prepare_isoforms/log_level"
                        }
                    ],
                    "out": [
                        "#pigeon_classify_scatter.cwl/prepare_isoforms/prepared_isoforms"
                    ],
                    "scatter": [
                        "#pigeon_classify_scatter.cwl/prepare_isoforms/input_files"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#pigeon_classify_scatter.cwl/prepare_isoforms"
                },
                {
                    "run": "#pigeon_prepare.cwl",
                    "in": [
                        {
                            "source": [
                                "#pigeon_classify_scatter.cwl/annotation_gtf",
                                "#pigeon_classify_scatter.cwl/reference_fa"
                            ],
                            "linkMerge": "merge_flattened",
                            "id": "#pigeon_classify_scatter.cwl/prepare_references/input_files"
                        },
                        {
                            "source": "#pigeon_classify_scatter.cwl/log_level",
                            "id": "#pigeon_classify_scatter.cwl/prepare_references/log_level"
                        }
                    ],
                    "out": [
                        "#pigeon_classify_scatter.cwl/prepare_references/prepared_annotation",
                        "#pigeon_classify_scatter.cwl/prepare_references/prepared_reference"
                    ],
                    "id": "#pigeon_classify_scatter.cwl/prepare_references"
                }
            ],
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_classify_scatter.cwl/classify_each/classification_txt",
                    "id": "#pigeon_classify_scatter.cwl/classification_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_classify_scatter.cwl/classify_each/junctions_txt",
                    "id": "#pigeon_classify_scatter.cwl/junctions_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": [
                            "null",
                            "File"
                        ]
                    },
                    "outputSource": "#pigeon_classify_scatter.cwl/prepare_isoforms/prepared_isoforms",
                    "doc": "Sorted isoforms GFF files from prepare step (to be used by filter workflow)",
                    "id": "#pigeon_classify_scatter.cwl/prepared_isoforms_gffs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_classify_scatter.cwl/classify_each/report_json",
                    "id": "#pigeon_classify_scatter.cwl/report_jsons"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_classify_scatter.cwl/classify_each/summary_txt",
                    "id": "#pigeon_classify_scatter.cwl/summary_txts"
                }
            ],
            "id": "#pigeon_classify_scatter.cwl"
        },
        {
            "class": "Workflow",
            "label": "Scatter pigeon filter and report across multiple classified samples",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Array of classification files",
                    "id": "#pigeon_filter_report_scatter.cwl/classification_txts"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#pigeon_filter_report_scatter.cwl/exclude_singletons"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#pigeon_filter_report_scatter.cwl/filter_threads"
                },
                {
                    "type": {
                        "type": "array",
                        "items": [
                            "null",
                            "File"
                        ]
                    },
                    "doc": "Array of sorted isoforms GFF files from classify step (may contain nulls)",
                    "id": "#pigeon_filter_report_scatter.cwl/isoforms_gffs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "doc": "Array of junctions files",
                    "id": "#pigeon_filter_report_scatter.cwl/junctions_txts"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "WARN",
                    "id": "#pigeon_filter_report_scatter.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 50,
                    "id": "#pigeon_filter_report_scatter.cwl/max_distance"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 3,
                    "id": "#pigeon_filter_report_scatter.cwl/min_cov"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#pigeon_filter_report_scatter.cwl/mono_exon"
                },
                {
                    "type": [
                        "null",
                        "float"
                    ],
                    "default": 0.6,
                    "id": "#pigeon_filter_report_scatter.cwl/polya_percent"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 6,
                    "id": "#pigeon_filter_report_scatter.cwl/polya_run_length"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#pigeon_filter_report_scatter.cwl/report_threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": false,
                    "id": "#pigeon_filter_report_scatter.cwl/skip_junctions"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#pigeon_filter_report_scatter.cwl/sub_sample_increment"
                }
            ],
            "steps": [
                {
                    "run": "#pigeon_filter.cwl",
                    "in": [
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/classification_txts",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/classification_txt"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/isoforms_gffs",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/isoforms_gff"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/junctions_txts",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/junctions_txt"
                        },
                        {
                            "valueFrom": "${\n  var basename = inputs.classification_txt.basename;\n  var sample = basename.replace(/_classification\\.txt$/, '');\n  return \"pigeon_filter_\" + sample + \".log\";\n}\n",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/log_file"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/log_level",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/log_level"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/max_distance",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/max_distance"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/min_cov",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/min_cov"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/mono_exon",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/mono_exon"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/polya_percent",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/polya_percent"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/polya_run_length",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/polya_run_length"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/skip_junctions",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/skip_junctions"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/filter_threads",
                            "id": "#pigeon_filter_report_scatter.cwl/filter_each/threads"
                        }
                    ],
                    "out": [
                        "#pigeon_filter_report_scatter.cwl/filter_each/filtered_classification_txt",
                        "#pigeon_filter_report_scatter.cwl/filter_each/filtered_junctions_txt",
                        "#pigeon_filter_report_scatter.cwl/filter_each/filtered_reasons_txt",
                        "#pigeon_filter_report_scatter.cwl/filter_each/filtered_gff",
                        "#pigeon_filter_report_scatter.cwl/filter_each/filtered_report_json",
                        "#pigeon_filter_report_scatter.cwl/filter_each/filtered_summary_txt"
                    ],
                    "scatter": [
                        "#pigeon_filter_report_scatter.cwl/filter_each/classification_txt",
                        "#pigeon_filter_report_scatter.cwl/filter_each/junctions_txt",
                        "#pigeon_filter_report_scatter.cwl/filter_each/isoforms_gff"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#pigeon_filter_report_scatter.cwl/filter_each"
                },
                {
                    "run": "#pigeon_report.cwl",
                    "in": [
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_classification_txt",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/classification_txt"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/exclude_singletons",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/exclude_singletons"
                        },
                        {
                            "valueFrom": "${\n  var basename = inputs.classification_txt.basename;\n  var sample = basename.replace(/\\.txt$/, '');\n  return \"pigeon_report_\" + sample + \".log\";\n}\n",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/log_file"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/log_level",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/log_level"
                        },
                        {
                            "valueFrom": "${\n  var basename = inputs.classification_txt.basename;\n  var sample = basename.replace(/\\.txt$/, '');\n  return sample + \".saturation.txt\";\n}\n",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/output_filename"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/sub_sample_increment",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/sub_sample_increment"
                        },
                        {
                            "source": "#pigeon_filter_report_scatter.cwl/report_threads",
                            "id": "#pigeon_filter_report_scatter.cwl/report_each/threads"
                        }
                    ],
                    "out": [
                        "#pigeon_filter_report_scatter.cwl/report_each/saturation_txt"
                    ],
                    "scatter": [
                        "#pigeon_filter_report_scatter.cwl/report_each/classification_txt"
                    ],
                    "scatterMethod": "dotproduct",
                    "id": "#pigeon_filter_report_scatter.cwl/report_each"
                }
            ],
            "outputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_classification_txt",
                    "id": "#pigeon_filter_report_scatter.cwl/filtered_classification_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": [
                            "File",
                            "null"
                        ]
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_gff",
                    "id": "#pigeon_filter_report_scatter.cwl/filtered_gffs"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_junctions_txt",
                    "id": "#pigeon_filter_report_scatter.cwl/filtered_junctions_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_reasons_txt",
                    "id": "#pigeon_filter_report_scatter.cwl/filtered_reasons_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_report_json",
                    "id": "#pigeon_filter_report_scatter.cwl/filtered_report_jsons"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/filter_each/filtered_summary_txt",
                    "id": "#pigeon_filter_report_scatter.cwl/filtered_summary_txts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#pigeon_filter_report_scatter.cwl/report_each/saturation_txt",
                    "id": "#pigeon_filter_report_scatter.cwl/saturation_txts"
                }
            ],
            "id": "#pigeon_filter_report_scatter.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "doc": "Adapters FASTA (e.g., params/mas8_primers.fasta)",
                    "id": "#skera.cwl/adapters_fa"
                },
                {
                    "type": "File",
                    "doc": "HiFi BAM file (e.g., *bc*.bam)",
                    "secondaryFiles": [
                        {
                            "required": false,
                            "pattern": ".pbi"
                        }
                    ],
                    "id": "#skera.cwl/hifi_bam"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#skera.cwl/log_file"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "INFO",
                    "id": "#skera.cwl/log_level"
                },
                {
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "segmented",
                    "id": "#skera.cwl/out_prefix"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "default": 0,
                    "id": "#skera.cwl/threads"
                },
                {
                    "type": [
                        "null",
                        "boolean"
                    ],
                    "default": true,
                    "id": "#skera.cwl/use_dataset_xml"
                }
            ],
            "steps": [
                {
                    "run": "#skera_split.cwl",
                    "in": [
                        {
                            "source": "#skera.cwl/adapters_fa",
                            "id": "#skera.cwl/skera_split/adapters_fa"
                        },
                        {
                            "source": "#skera.cwl/hifi_bam",
                            "id": "#skera.cwl/skera_split/in_bam"
                        },
                        {
                            "source": "#skera.cwl/log_file",
                            "id": "#skera.cwl/skera_split/log_file"
                        },
                        {
                            "source": "#skera.cwl/log_level",
                            "id": "#skera.cwl/skera_split/log_level"
                        },
                        {
                            "source": "#skera.cwl/out_prefix",
                            "id": "#skera.cwl/skera_split/out_prefix"
                        },
                        {
                            "source": "#skera.cwl/threads",
                            "id": "#skera.cwl/skera_split/threads"
                        },
                        {
                            "source": "#skera.cwl/use_dataset_xml",
                            "id": "#skera.cwl/skera_split/use_dataset_xml"
                        }
                    ],
                    "out": [
                        "#skera.cwl/skera_split/segmented_bam",
                        "#skera.cwl/skera_split/non_passing_bam",
                        "#skera.cwl/skera_split/segmented_dataset",
                        "#skera.cwl/skera_split/summary_csv",
                        "#skera.cwl/skera_split/ligations_csv",
                        "#skera.cwl/skera_split/read_lengths_csv",
                        "#skera.cwl/skera_split/adapters_csv_gz"
                    ],
                    "id": "#skera.cwl/skera_split"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#skera.cwl/skera_split/adapters_csv_gz",
                    "id": "#skera.cwl/adapters_csv_gz"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#skera.cwl/skera_split/ligations_csv",
                    "id": "#skera.cwl/ligations_csv"
                },
                {
                    "type": "File",
                    "outputSource": "#skera.cwl/skera_split/non_passing_bam",
                    "id": "#skera.cwl/non_passing_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#skera.cwl/skera_split/read_lengths_csv",
                    "id": "#skera.cwl/read_lengths_csv"
                },
                {
                    "type": "File",
                    "outputSource": "#skera.cwl/skera_split/segmented_bam",
                    "id": "#skera.cwl/segmented_bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#skera.cwl/skera_split/segmented_dataset",
                    "id": "#skera.cwl/segmented_dataset"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#skera.cwl/skera_split/summary_csv",
                    "id": "#skera.cwl/summary_csv"
                }
            ],
            "id": "#skera.cwl"
        }
    ],
    "cwlVersion": "v1.2"
}
