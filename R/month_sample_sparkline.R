

#' make a plot of months that will be suitable for sparklining
#' @param tib a tibble like what you have in the data column of fbmet2
#' @param path the path to write the pdf file to
month_sample_sparkline <- function(tib, path) {

  source("R/colors.R")

  # first letters of each month
  first_letters <- tibble(
    letter = c("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"),
    pos = 1:12
  )

  t2 <- tib %>%
    filter(yday(collection_date) != 1) %>%  # this is for cases where the exact day of sampling is unknown, and denoted YYYY-01-01
    filter(!is.na(month)) %>%
    mutate(month = as.integer(month)) %>%
    count(month, run_timing) %>%
    mutate(fract = n/sum(n))

  g <- ggplot() +
    geom_rect(data = t2, mapping = aes(xmin = month - 0.45, xmax = month + 0.45, ymin = 0, ymax = fract, fill = run_timing, colour = run_timing)) +
    scale_fill_manual(values = run_time_colors) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    geom_hline(yintercept = c(0, 1)) +
    scale_x_continuous(limits = c(0, 13)) +
    theme_void() +
    theme(legend.position = "none") +
    geom_text(
      data = first_letters,
      mapping = aes(x = pos, y = 0.5, label = letter),
      hjust = 0.5, vjust = 0.5,
      size = 10,
      colour = "gray60"
    )

  ggsave(g, filename = path, width = 5, height = 0.6)

  return(g)

}
