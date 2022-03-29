get_ <- function(resource, ...) {
  params <- list(
    ...
  )

  # Convert logical parameters to character with values "True" and "False"
  params <- lapply(params, function(x) {`if`(is.logical(x), logical_to_character(x), x)})

  base_url <- 'https://oncotree.info/api'

  httr2::request(base_url) %>%
    httr2::req_url_path_append(resource) %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_headers(Accept = 'application/json') %>%
    httr2::req_user_agent("R package mskcc.oncotree (https://maialab.org/mskcc.oncotree)") %>%
    httr2::req_perform() %>%
    httr2::resp_body_string(encoding = "UTF-8")
}

get <- memoise::memoise(get_)
