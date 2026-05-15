## test run for skera workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/skera_test \
	workflows/skera.cwl \
	params/skera_test.yml

## test run for lima_isoseq workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/lima_isoseq_test \
	tools/lima_isoseq.cwl \
	params/lima_isoseq_test.yml

## test run for isoseq_refine workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/isoseq_refine_test \
	workflows/isoseq_refine_scatter.cwl \
	params/isoseq_refine_scatter_dir_test.yml

## test run for isoseq_cluster2 workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/isoseq_cluster2_test \
	workflows/isoseq_cluster2_scatter.cwl \
	params/isoseq_cluster2_scatter_dir_test.yml

## test run for pbmm2_align_scatter workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/pbmm2_align_scatter_test \
	workflows/pbmm2_align_scatter.cwl \
	params/pbmm2_align_scatter_test.yml

## test run for isoseq_collapse_scatter workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/isoseq_collapse_scatter_test \
	workflows/isoseq_collapse_scatter.cwl \
	params/isoseq_collapse_scatter_test.yml

## test run for pigeon_classify_scatter workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/pigeon_classify_scatter_test \
	workflows/pigeon_classify_scatter.cwl \
	params/pigeon_classify_scatter_test.yml

## test run for pigeon_filter_report_scatter workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/pigeon_filter_report_scatter_test \
	workflows/pigeon_filter_report_scatter.cwl \
	params/pigeon_filter_report_scatter_test.yml

# test run for full kinnex processing workflow
cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/kinnex_output_test2 \
	kinnex_longreads.cwl \
	params/kinnex_params.yml

mkdir -p logs

cwltool \
	--leave-tmpdir \
	--tmpdir-prefix ./.cwl-tmp/ \
	--tmp-outdir-prefix ./.cwl-out/ \
	--outdir outputs/multi_smrt_cells_example \
	kinnex_longreads.cwl \
	params/multiple_smrt_cells_example.yml 2>&1 | tee logs/multi_smrt_cells_example.log

# deploy to Cavatica
cwltool --validate kinnex_longreads.cwl
sbpack cavatica childrens-bti/rokita-longread-rna-harmonization/kinnex-longreads /home/ubuntu/kinnex_longreads/kinnex_longreads.cwl