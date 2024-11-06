

# Anthony noted that the primer pairs were reversed in the supp data.
# So, we just want to fix that here.

# Here is what Anthony said:
# I was just further perusing this table and it looks like the
# forward and reverse primers are swapped for the SNPlicon markers.
# It certainly doesn't really matter for the chemistry, but looking
# back at the actual IDT order forms, the forward primers start
# with CGA and the reverse with GTG.


# So, let's put the current state of things into the directory where this
# script is and fix it.
library(tidyverse)
x <- read_csv("extras/Reordering-forward-and-reverse-primers/OLD-Calif-Chinook-Amplicon-Panel-Information.csv")


# this should be easy:
check_it <- x %>%
  mutate(
    tmp_forward = case_when(
      str_detect(ForwardPrimerSequence, "^CGA") ~ ForwardPrimerSequence,
      str_detect(ReversePrimerSequence, "^CGA") ~ ReversePrimerSequence,
      TRUE ~ "BAD NEWS FORWARD!!"
    ),
    tmp_reverse = case_when(
      str_detect(ReversePrimerSequence, "^GTG") ~ ReversePrimerSequence,
      str_detect(ForwardPrimerSequence, "^GTG") ~ ForwardPrimerSequence,
      TRUE ~ "BAD NEWS REVERSE!!"
    ),
    .before = ForwardPrimerSequence
  )


# that all checks out, so now just copy those to the original columns and remove
final <- check_it %>%
  mutate(
    ForwardPrimerSequence = tmp_forward,
    ReversePrimerSequence = tmp_reverse
  ) %>%
  select(-tmp_forward, -tmp_reverse)


write_csv(final, "inputs/Calif-Chinook-Amplicon-Panel-Information.csv")
write_csv(final, "tex/supp_data/Supp-Data-1-Amplicon-info.csv")
