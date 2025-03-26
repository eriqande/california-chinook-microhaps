if(exists("snakemake")) {
  
  # redirect output and messages/errors to the log
  log <- file(snakemake@log[[1]], open="wt")
  sink(log, type = "output")
  sink(log, type = "message")
  
  sgfile <- snakemake@input$sg
  lf_v_frhf_lrts <- snakemake@input$lf_v_frhf_lrts
  lf_v_sanjo_lrts <- snakemake@input$lf_v_sanjo_lrts
  outfile <- snakemake@output$mh_plot
  neg10 <- as.numeric(snakemake@params$neg_log10_cutoff)
}

require(tidyverse)
require(vroom)





#' function to process the data for a manhattan plot
#' @param sgfile the scaffold groups file
#' @param lrt_files vector of paths to lrt0.gz files (one for each chrom, etc.)
#' @param outfile path to the output file.  Extension (.pdf/.jpg/etc) determines type
#' @param neg_log10_cutoff  value below which you want to filter out points to make the
#' plot smaller.
mh_plot_data <- function(
    sgfile = "inputs/scaffold_groups.tsv",
    lrt_files = c(list.files(path="results/doAsso/lf_v_frhf", pattern = ".*lrt0.gz", full.names = TRUE),
                  list.files(path="results/doAsso_unplaced/lf_v_frhf", pattern = ".*lrt0.gz", full.names = TRUE)),
    neg_log10_cutoff=3
) {
  # first, get the cumulative position of the start of each chromosome
  sg <- read_tsv(sgfile) %>%
    mutate(
      cstart = 1 + lag(cumsum(stop), default = 0),
      cend = cstart + stop - 1
    )
  
  # read in the LRTs and process them
  r <- vroom(lrt_files) %>%
    filter(LRT != -999) %>% # remove missing ones
    mutate(neg_log10_p = -log10(pchisq(LRT, df = 1, lower.tail = FALSE))) %>%
    filter(neg_log10_p > neg_log10_cutoff) %>% 
    left_join(
      .,
      sg %>% select(chrom, mh_label, angsd_chrom, cstart),
      by = c("Chromosome" = "chrom")
    ) %>%
    mutate(xpos = Position + cstart - 1) %>%
    mutate(  # put each successive chromosome/scaff group into a separate group (a or b)
      cnf = factor(mh_label, levels = unique(mh_label)),
      cgroup = c("a", "b")[1 + as.integer(cnf) %% 2]
    )
  
  
  # finally, we are going to want to get a tibble that tells
  # us where the chromosome labels should go
  cmids <- sg %>%
    group_by(mh_label) %>%
    summarise(xmid = (min(cstart) + max(cend)) / 2 )
  
  
  # return these data
  list(dat = r, cmids = cmids)
  
}




FRHF <- mh_plot_data(
  sgfile = sgfile,
  lrt_files = lf_v_frhf_lrts,
  neg_log10_cutoff = neg10
)

SANJO <- mh_plot_data(
  sgfile = sgfile,
  lrt_files = lf_v_sanjo_lrts,
  neg_log10_cutoff = neg10
)

# here we make the plot
r <- bind_rows(
  list(
    `Late Fall versus Feather River Hatchery Fall` = FRHF$dat,
    `Late Fall versus San Joaquin River Fall` = SANJO$dat
  ),
  .id = "comparison"
)

cmids <- FRHF$cmids 

g <- ggplot(r) +
  geom_point(aes(x = xpos / 1e6, y = neg_log10_p, colour = cgroup), size = 0.5) +
  theme_bw() +
  scale_colour_manual(values = c(a = "skyblue", b = "gray80")) +
  xlab("Megabases") +
  ylab("Negative log10 of p-value") +
  geom_text(
    data = cmids,
    mapping = aes(x = xmid / 1e6, y = 0.2, label = mh_label),
    size = 2.8,
    angle = 90,
    hjust = 0,
    vjust = 0.5
  ) +
  geom_hline(yintercept = -log10(5e-8), linetype = "dashed") +
  theme(text = element_text(family = "sans"), legend.position = "none") +
  facet_wrap(~comparison, ncol = 1) +
  scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0.01, 0.05))) +
  scale_x_continuous(breaks = seq(0, 2000, by = 500), expand = expansion(mult = c(0.01, 0.01)))
  
 

ggsave(g, filename = outfile, width = 13, height = 5)
