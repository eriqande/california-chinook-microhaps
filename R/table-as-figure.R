require(tidyverse)

#' A function to create a table as a figure
#'
#' This is intended for non-symmetrical measures, so that the table
#' is represented as a full matrix. These labels will
#' go on both the right and left sides, as well as the top and bottom.
#'
#' The primary reason for doing this is to create a table as a figure
#' with text labels and also colors in some of the cells, and also
#' in the row and column labels.
#' @param X a tibble with the columns:
#'   - row_label: a factor, which row is should be in
#'   - col_label: a factor, which column it should be in
#'   - cell_label: a character vector of what goes in the cell
#'   - cell_fill: a character vector that will be mapped to colors.
#'   Should be "white" if it is to be left as white.
#' @param RC_groups a tibble with two columns:
#'   - external group: the group that each row_label belongs to, that it will be colored
#'     by in the external labels.
#'   - internal_group: the group that the row/column belongs to inside the table.  These
#'     should be contiguous
#'   - label: the label itself, as a character vector. The whole tibble
#'     Should be ordered by label according to the row_label factor levels in X
#' @param external_colors a named vector with the names being the groups
#' found in RC_groups$external_group and the values being colors
#' @param internal_colors a named vector with the names being the groups
#' found in RC_groups$internal_group and the values being colors
#' @param Xs_on_diagonal  If TRUE then line segments are drawn in a big X along
#' the diagonal (i.e., for Fst values, etc.)
table_as_figure <- function(
    X,
    RC_groups,
    internal_colors,
    external_colors,
    internal_color_legend_name = "Genetic-marker-resolvable\ngenomic background",
    external_color_legend_name = "Nominal group based\non run timing",
    Xs_on_diagonal = FALSE,
    skinny_line_width = 0.3,
    thick_line_width = 1.3,
    plot_margins = c(0, 0, 1.5, 0)
) {

  # first, expand X to include the xmin/max and ymin/ymax for each internal cell
  N <- length(levels(X$row_label))
  X2 <- X %>%
    mutate(
      ymin = N - as.integer(row_label),
      ymax = N - as.integer(row_label) + 1,
      xmin = as.integer(col_label) - 1,
      xmax = as.integer(col_label)
    )

  # now, create another tibble with all the information for plotting
  # the row and column label cells.  To assist in that we make a function.
  # this operates on a single factor values and returns a tibble with the
  # L, R, T, B (left, right, top, bottom) rectangle limits for these
  return_xy_mins_and_maxes <- function(f) {
    tibble(
      location = c("L", "R", "T", "B"),
      ymin = c(N - as.integer(f), N - as.integer(f), N, -1),
      ymax = ymin + 1,
      xmin = c(-1, N, as.integer(f) - 1, as.integer(f) - 1),
      xmax = xmin + 1
    )
  }


  # and use that function to get the tibble we need
  Z <- tibble(
    label = factor(levels(X$row_label), levels = levels(X$row_label))
  ) %>%
    mutate( # the first of each pair will be the top
      stuff = map(label, return_xy_mins_and_maxes)
    ) %>%
    unnest(cols = stuff) %>%
    left_join(RC_groups, by = c("label" = "label"))



  # make a convenience tibble for plotting thick perimeter lines
  perim_thick <- expand_grid(
    x = c(0, N),
    xend = c(0, N),
    y = c(0, N),
    yend = c(0, N)
  ) %>%
    filter(xor(x != xend, y != yend) & x <= xend & y <= yend)

  # then, also get the values for plotting the thick internal lines
  internal_lines_tib <- RC_groups %>%
    mutate(val = 1:n()) %>%
    group_by(internal_group) %>%
    summarise(val = last(val)) %>%
    filter(val != max(val))

  # then put these together into a big ggplot
  full_plot <- ggplot() +
    geom_rect(  # outer edge filled rectangles
      data = Z,
      mapping = aes(
        xmin = xmin,
        xmax = xmax,
        ymin = ymin,
        ymax = ymax,
        fill = external_group
      )
    ) +
    geom_label( # outer edge labels
      data = Z,
      mapping = aes(
        x = (xmin + xmax) / 2,
        y = (ymin + ymax) / 2,
        label = label
      ),
      vjust = 0.5,
      hjust = 0.5
    ) +
    geom_rect(  # inner filled rectangles
      data = X2,
      mapping = aes(
        xmin = xmin,
        xmax = xmax,
        ymin = ymin,
        ymax = ymax,
        fill = cell_fill
      )
    ) +
    geom_text( # interior cell labels
      data = X2,
      mapping = aes(
        x = (xmin + xmax) / 2,
        y = (ymin + ymax) / 2,
        label = cell_label
      ),
      vjust = 0.5,
      hjust = 0.5
    ) +
    geom_segment(  # get thick lines around the interior perimeter
      data = perim_thick,
      mapping = aes(x = x, xend = xend, y = y, yend = yend),
      linewidth = thick_line_width
    ) +
    geom_vline(xintercept = seq(0, N, by = 1), linewidth = skinny_line_width) +
    geom_hline(yintercept = seq(0, N, by = 1), linewidth = skinny_line_width) +
    geom_vline(xintercept = internal_lines_tib$val, linewidth = thick_line_width) +
    geom_hline(yintercept = N - internal_lines_tib$val, linewidth = thick_line_width) +
    coord_cartesian(xlim = c(-1, N+1), ylim = c(-1, N+1), expand = FALSE) +
    scale_fill_manual(values = c(external_colors, internal_colors), na.value = "white") +
    theme_void() +
    theme(
      legend.position = "none",
      plot.margin = unit(plot_margins, "lines")
    )


  if(Xs_on_diagonal == TRUE) {
    # get a tibble of where those Xs will go:
    Xs <- X2 %>%
      filter(row_label == col_label)

    full_plot <- full_plot +
      geom_segment(data = Xs, aes(y = ymin + 0.5, x = xmin, yend = ymin + 0.5, xend = xmax), linewidth = thick_line_width) +
      geom_segment(data = Xs, aes(y = ymin, x = xmin + 0.5, yend = ymax, xend = xmin + 0.5), linewidth = thick_line_width) +
      geom_segment(data = Xs, aes(y = ymax, x = xmin, yend = ymax - 0.5, xend = xmin), linewidth = thick_line_width) +
      geom_segment(data = Xs, aes(y = ymax, x = xmin, yend = ymax, xend = xmin + 0.5), linewidth = thick_line_width) +
      geom_segment(data = Xs, aes(y = ymin, x = xmin + 0.5, yend = ymin, xend = xmax), linewidth = thick_line_width) +
      geom_segment(data = Xs, aes(y = ymin, x = xmax, yend = ymin + 0.5, xend = xmax), linewidth = thick_line_width)
  }

  # now, we also want to make some dummy plots from which we can grab
  # the legends with cowplot
  for_external_legend <- RC_groups %>%
    mutate(egf = factor(external_group, levels = unique(external_group))) %>%
    ggplot(aes(x = egf, fill = egf)) +
    geom_bar(color = "black") +
    scale_fill_manual(
      values = external_colors,
      name = external_color_legend_name
    )

  for_internal_legend <- RC_groups %>%
    mutate(igf = factor(internal_group, levels = unique(internal_group))) %>%
    ggplot(aes(x = igf, fill = igf)) +
    geom_bar(color = "black") +
    scale_fill_manual(
      values = internal_colors,
      name = internal_color_legend_name
    )

  # then return those three plots so that we can use cowplot to
  # put the legends the way we want.
  # see: https://stackoverflow.com/questions/27803710/ggplot2-divide-legend-into-two-columns-each-with-its-own-title
  list(
    full_plot = full_plot,
    for_internal_legend = for_internal_legend,
    for_external_legend = for_external_legend
  )

}
