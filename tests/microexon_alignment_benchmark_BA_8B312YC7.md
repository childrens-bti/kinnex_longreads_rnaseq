# Microexon alignment benchmark: BA_8B312YC7

## Scope

This comparison uses all 413,620 clustered transcript records from
`BA_8B312YC7.SR009023_Kinnex`. An exon is counted as detected only when an
internal CIGAR block exactly matches its GENCODE v39 genomic start, end, and
strand.

## Results

| Method | Settings | Confirmed <=10-nt targets | 1-10 nt GENCODE loci | 11-20 nt GENCODE loci | 21-30 nt GENCODE loci |
|---|---|---:|---:|---:|---:|
| pbmm2 | `--preset ISOSEQ` (`-k 15 -w 5`) | 6/100 (6.0%) | 7/337 (2.1%) | 287/767 (37.4%) | 903/2,448 (36.9%) |
| minimap2 | `-x splice:hq -uf --secondary=no --junc-bed -k 15 -w 5` | 99/100 (99.0%) | 111/337 (32.9%) | 296/767 (38.6%) | 906/2,448 (37.0%) |
| uLTRA | Coordinate-sorted GENCODE v39; `uLTRA index --disable_infer`; `uLTRA align --isoseq` | 84/100 (84.0%) | 91/337 (27.0%) | 284/767 (37.0%) | 908/2,448 (37.1%) |

## Interpretation

Annotation-guided minimap2 had the best recovery of the sequence-confirmed
<=10-nt microexons (99/100). uLTRA recovered 84/100, substantially more than
pbmm2 (6/100), but fewer than minimap2 with the junction BED.

uLTRA requires its input annotation to be coordinate-sorted within each
chromosome. The workflow now performs that sort before constructing the uLTRA
index.

## Artifacts

- Scorer and result tables:
  `outputs/minimap2_junction_BA_8B312YC7/compare_microexon_alignments.py`,
  `outputs/full_aligner_benchmark_BA_8B312YC7/microexon_comparison_three_methods.json`
- Alignment outputs:
  `outputs/full_aligner_benchmark_BA_8B312YC7/`
