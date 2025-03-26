scaffs <- read_tsv("inputs/scaffold_groups.tsv") %>% 
  mutate(num = as.integer(str_replace_all(id, "[a-z_]*", ""))) %>% 
  filter(num >= 35) %>%
  mutate(grp = rep(seq(1:28), each = 500)[1:n()] ) %>%
  mutate(id = sprintf("unplaced-%03d", grp)) %>%
  mutate(rstr = str_c(chrom, ":", start, "-", stop))


dir.create("inputs/region_files")

scaffs %>%
  select(id, rstr) %>%
  group_by(id) %>%
  nest() %>%
  ungroup() %>%
  mutate( what = walk2(
    .x = id,
    .y = data,
    .f = function(x, y) write_tsv(y, col_names = FALSE, file = str_c("inputs/region_files/", x, ".txt")))
)
