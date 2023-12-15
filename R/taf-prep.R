require(tidyverse)

#' simple function to take rubias output and prep it
#' for the table_as_figure function
taf_prep <- function(X) {
  X %>% rename(
    row_label = collection_f,
    col_label = inferred_coll_f,
  ) %>%
    mutate(
      cell_label = as.character(n)
    ) %>%
    select(-n) %>%
    left_join(
      pop_labels %>% select(collection, repunit),
      by = c("row_label" = "collection"),
      keep = TRUE
    ) %>%
    select(-collection) %>%
    rename(row_rep = repunit) %>%
    left_join(
      pop_labels %>% select(collection, repunit),
      by = c("col_label" = "collection"),
      keep = TRUE
    ) %>%
    select(-collection) %>%
    rename(col_rep = repunit) %>%
    mutate(
      cell_fill = case_when(
        row_rep == col_rep ~ row_rep,
        TRUE ~ NA_character_
      )
    ) %>%
    select(-col_rep, -row_rep)

}
