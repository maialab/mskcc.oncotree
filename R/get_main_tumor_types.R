get_main_tumor_types_ <- function() {

  resp <- get("/mainTypes")

  resp %>%
    tidyjson::gather_array() %>%
    tidyjson::append_values_string('oncotree_main_type') %>%
    tidyjson::as_tibble() %>%
    dplyr::select(-c('document.id', 'array.index'))
}

#' @keywords internal
get_main_tumor_types <- memoise::memoise(get_main_tumor_types_)
