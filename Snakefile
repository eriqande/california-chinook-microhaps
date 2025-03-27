


# this rule all generates all the figures and tables
# for the paper and the supplement
rule all:
    input:
        "docs/001-map-of-samples.html",
        "docs/002-GSI_and_Fst.html",
        "docs/003-ckmr-sim-evaluation.html",
        "docs/004-lfar-and-wrap-allele-freqs.html",
        "docs/005-plotting-genome-locations-of-markers.html",
        "docs/006-winter-run-vs-all-cv-alle-freqs.html",
        "docs/007-whoa-on-chinook.html",
        "docs/008-lfar-gwas-and-markers.html",
        "docs/009-structure.html",
        texmap = "tex/images/map-crop.pdf",                             # Figure 1
        tex_table = "tex/inputs/samples-table.tex",                     # Table 1
        gsi_fst_fig_tex = "tex/images/gsi_and_fst_fig-crop.pdf",        # Figure 2
        ass_table80_tex = "tex/images/ass-table-80-crop.pdf",           # Figure S6
        rosa_gsi_table_tex = "tex/images/rosa-gsi-table-crop.pdf",      # Figures S7
        pop_gen_by_loc_coll = "tex/supp_data/Supp-Data-2-pop-gen-summaries-by-locus-and-collection.csv",  # Supp Data 2
        num_alle_barplot = "tex/images/num-alle-barplot.pdf",           # Figure S4
        popgen_summ = "tex/inputs/popgen-summary.tex",                  # Table 4
        ckmr_figure_tex = "tex/images/fpr-fnr-figure-crop.pdf",         # Figure 4
        #ckmr_comp_tex = "tex/images/cmkr-comp-figure-crop.pdf",        # Figure S8, but ggsave fails on it so it was exported by hand
        frh_comp_tex = "tex/images/frh-comp-figure-crop.pdf",           # Figure 5
        lfar_tex_table = "tex/inputs/lfar-freqs.tex",                   # Table 3
        wrap_tex_table = "tex/inputs/wrap-freqs.tex",                   # Table S2
        genome_locations_tex = "tex/images/genomic-locations-plot.pdf", # Figure S1
        winter_v_nonwinter_mh_tex = "tex/images/winter-v-non-winter-mh-plot_nind_ge10.pdf", # Figure S9
        hundy_kb4tex = "tex/images/wrap-slide-window.pdf",              # Figure S10
        wrap61_4tex = "tex/images/wrap-candi.pdf",                      # Figure S11
        whoa_zs = "results/whoa/heterozygote-z-scores.pdf",             # Not included in final paper
        lfar_candidates_tex = "tex/images/lfar-candidates.pdf",          # Figure S3






rule map_of_samples:
    input:
        rmd="001-map-of-samples.Rmd",
        oregon_rivers = "inputs/Rivers_OR/Rivers_OR.shp"
    output:
        html="docs/001-map-of-samples.html",
        texmap = "tex/images/map-crop.pdf"
    log:
        "results/logs/map_of_samples.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule GSI_and_Fst:
    input:
        rmd="002-GSI_and_Fst.Rmd",
        final_baseline = "data/SWFSC-chinook-reference-baseline.csv.gz",
        pop_labels = "inputs/reference-collection-names.csv",
        map_notations = "inputs/map-notations.tsv"
    output:
        html="docs/002-GSI_and_Fst.html",
        tex_table = "tex/inputs/samples-table.tex",
        gsi_fst_fig_tex = "tex/images/gsi_and_fst_fig-crop.pdf",
        ass_table80_tex = "tex/images/ass-table-80-crop.pdf",
        rosa_gsi_table_tex = "tex/images/rosa-gsi-table-crop.pdf",
        pop_gen_by_loc_coll = "tex/supp_data/Supp-Data-2-pop-gen-summaries-by-locus-and-collection.csv",
        popgen_summ = "tex/inputs/popgen-summary.tex",
        num_alle_barplot = "tex/images/num-alle-barplot.pdf"
    log:
        "results/logs/GSI_and_Fst.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule ckmr_sim_evaluation:
    input:
        rmd="003-ckmr-sim-evaluation.Rmd",
        final_baseline = "data/SWFSC-chinook-reference-baseline.csv.gz",
        pop_labels = "inputs/reference-collection-names.csv",
        locus_info = "inputs/Calif-Chinook-Amplicon-Panel-Information.csv"
    output:
        html="docs/003-ckmr-sim-evaluation.html",
        ckmr_figure_tex = "tex/images/fpr-fnr-figure-crop.pdf",
        frh_comp_tex = "tex/images/frh-comp-figure-crop.pdf"
    log:
        "results/logs/ckmr_sim_evaluation.log"
    conda:
        "envs/pandoc.yaml"
    threads: 8
    script:
        "scripts/render-rmd-for-snakemake.R"



rule lfar_and_wrap_allele_freqs:
    input:
        rmd="004-lfar-and-wrap-allele-freqs.Rmd",
        final_baseline = "data/SWFSC-chinook-reference-baseline.csv.gz",
        pop_labels = "inputs/reference-collection-names.csv",
        locus_info = "inputs/Calif-Chinook-Amplicon-Panel-Information.csv"
    output:
        html="docs/004-lfar-and-wrap-allele-freqs.html",
        lfar_tex_table = "tex/inputs/lfar-freqs.tex",
        wrap_tex_table = "tex/inputs/wrap-freqs.tex"
    log:
        "results/logs/lfar_and_wrap_allele_freqs.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule plotting_genome_locations_of_markers:
    input:
        rmd="005-plotting-genome-locations-of-markers.Rmd",
        locus_info = "inputs/Calif-Chinook-Amplicon-Panel-Information.csv",
        chr_len = "inputs/Otsh_v2.0_chrom_lengths.tsv"
    output:
        html="docs/005-plotting-genome-locations-of-markers.html",
        genome_locations_tex = "tex/images/genomic-locations-plot.pdf"
    log:
        "results/logs/plotting_genome_locations_of_markers.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule winter_run_vs_all_cv_alle_freqs:
    input:
        rmd="006-winter-run-vs-all-cv-alle-freqs.Rmd",
        wrap_chr_len = "inputs/wrap/chrom_lengths.txt",
        win_non_win_abs_diffs = "stored_results/win-non-win-abs-diffs-gt0.5.rds"
    output:
        html="docs/006-winter-run-vs-all-cv-alle-freqs.html",
        winter_v_nonwinter_mh_tex = "tex/images/winter-v-non-winter-mh-plot_nind_ge10.pdf",
        hundy_kb4tex = "tex/images/wrap-slide-window.pdf",
        wrap61_4tex = "tex/images/wrap-candi.pdf"
    log:
        "results/logs/winter_run_vs_all_cv_alle_freqs.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule whoa_on_chinook:
    input:
        rmd="007-whoa-on-chinook.Rmd",
        final_baseline = "data/SWFSC-chinook-reference-baseline.csv.gz",
        pop_labels = "inputs/reference-collection-names.csv"
    output:
        html="docs/007-whoa-on-chinook.html",
        whoa_zs = "results/whoa/heterozygote-z-scores.pdf"
    log:
        "results/logs/whoa_on_chinook.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule lfar_gwas_and_markers:
    input:
        rmd="008-lfar-gwas-and-markers.Rmd",
        chr34_late_fall_mafs = "stored_results/5Mb_Chr34-late-fall.mafs.gz",
        chr34_cv_fall_mafs = "stored_results/5Mb_Chr34-cv-fall.mafs.gz",
        gwas_lf_v_sanjo = "stored_results/lfar-gwas/lf_v_sanjo-NC_037130.1.lrt0.gz",
        gwas_lf_v_frhf = "stored_results/lfar-gwas/lf_v_frhf-NC_037130.1.lrt0.gz",
        ots34_snpeff = "stored_results/thompson2020-vcf/ots34-5Mb-snpEff.vcf.gz",
        pvals = "stored_results/stored_p_vals.rds"
    output:
        html="docs/008-lfar-gwas-and-markers.html",
        lfar_candidates_tex = "tex/images/lfar-candidates.pdf"
    log:
        "results/logs/lfar_gwas_and_markers.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"



rule structure:
    input:
        rmd="009-structure.Rmd"
    output:
        html="docs/009-structure.html"
    log:
        "results/logs/structure.log"
    conda:
        "envs/pandoc.yaml"
    script:
        "scripts/render-rmd-for-snakemake.R"
