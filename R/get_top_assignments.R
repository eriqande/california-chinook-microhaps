

#' Get the top assignments from the self_assign() output
#'
#' We assign to repunit, then assign to the most likely collection
#' within the most likely repunit
#' @param full_sa The full output tibble from the self_assign() function
#' @param collection_order A vector giving the order you want the collections
#' sorted.  It creates a factor coll_f from this.
get_top_assignments <- function(full_sa, collection_order) {

  repu_likes <- full_sa %>%
    group_by(indiv, collection, repunit, inferred_repunit) %>%
    mutate(repu_sclike = sum(scaled_likelihood))

  top <- repu_likes %>%
    group_by(indiv) %>%
    filter(repu_sclike == max(repu_sclike)) %>%
    arrange(indiv, desc(scaled_likelihood)) %>%
    slice(1) %>%
    ungroup() %>%
    mutate(coll_f = factor(collection, levels = collection_order))

  list(
    top = top,
    repu_likes = repu_likes
  )
}
