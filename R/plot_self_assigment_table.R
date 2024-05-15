
#' from the top-assignments make a colorful assignment table
#'
#' The top assignments are like those that come out of get_top_assignments()
#' or a filtered version thereof
#' @param pop_labels  The pop_labels tibble
#' @param top_ass the top assignments. If it has a column "rosa_geno" then this
#' will trigger counting things broken down by rosa_geno, too.
#' @param collection_order A vector giving the order you want the collections
#' sorted.
#' @return Returns a list.  Component "plot" of which is the ggplot of the assignment
#' table, and component RFL is the Rubias_for_later output---basically
#' the top assignments with some factors in there for getting the order right.
plot_self_assignment_table <- function(top_ass, pop_labels, collection_order, no_legend = FALSE, zeros_are_empty = TRUE) {

  # get the function
  source("R/taf-prep.R")
  source("R/table-as-figure.R")

  # get the RC_groups
  RC_groups <- pop_labels %>%
    select(-old_name) %>%
    distinct() %>%
    rename(external_group = run_timing_group, internal_group = repunit, label = collection) %>%
    select(external_group, internal_group, label)

  if(!("rosa_geno" %in% names(top_ass))) {
    X2 <- top_ass %>%
      mutate(
        collection_f = factor(collection, levels = collection_order),
        inferred_coll_f = factor(inferred_collection, levels = collection_order)
      ) %>%
      count(collection_f, inferred_coll_f, .drop = FALSE) %>%
      taf_prep()

    # remove 0's if desired
    if(zeros_are_empty == TRUE) {
      X2 <- X2 %>%
        mutate(cell_label = ifelse(cell_label == "0", "", cell_label))
    }

  } else {
    X2 <- top_ass %>%
      mutate(
        collection_f = factor(collection, levels = collection_order),
        inferred_coll_f = factor(inferred_collection, levels = collection_order),
        rosa_geno_f = factor(rosa_geno, levels = c("EE", "EL", "LL"))
      ) %>%
      count(collection_f, inferred_coll_f, rosa_geno_f, .drop = FALSE) %>%
      taf_prep()

    # here, we remove zeros only from the cells that are ALL zero
    if(zeros_are_empty == TRUE) {
      X2 <- X2 %>%
        group_by(row_label, col_label) %>%
        mutate(cell_label = ifelse(rep(all(cell_label == "0"), n()), "", cell_label))
    }
  }

  Rubias_for_later <- X2 # keeping this for later...

  # get the result
  TAF2 <- table_as_figure(
    X = X2,
    RC_groups = RC_groups,
    external_colors = run_time_colors,
    internal_colors = repunit_colors,
    plot_margins = c(1, 0.1, 0.7, 0.1)
  )

  # and plot it
  if(!no_legend) {
    g <- plot_grid(
      TAF2$full_plot,
      plot_grid(
        get_legend(TAF2$for_external_legend),
        get_legend(TAF2$for_internal_legend),
        nrow = 1
      ),
      nrow = 2,
      rel_heights = c(7,3)
    )
  } else {
    g <- TAF2$full_plot
  }

  list(
    plot = g,
    RFL = Rubias_for_later,
    for_external_legend = TAF2$for_external_legend,
    for_internal_legend = TAF2$for_internal_legend
  )
}
