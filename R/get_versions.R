
#' @importFrom rlang .data
#' @keywords internal
get_versions_ <- function() {

  resp <- get("/versions")

  resp %>%
    tidyjson::gather_array() %>%
    tidyjson::spread_all() %>%
    tidyjson::as_tibble() %>%
    dplyr::select(-c('document.id', 'array.index')) %>%
    dplyr::rename(oncotree_version = .data$api_identifier) %>%
    dplyr::arrange(dplyr::desc(.data$release_date))

}

#' Get OncoTree versions
#'
#' @return A [tibble][tibble::tibble-package] of four variables:
#' \describe{
#' \item{`oncotree_version`}{OncoTree tumor classification system version.}
#' \item{`description`}{OncoTree release description.}
#' \item{`visible`}{A logical indicating whether this OncoTree version is visible, i.e. a forefront option at the website.}
#' \item{`release_date`}{OncoTree release date.}
#' }
#' @md
#'
#' @examples
#' \dontrun{
#' get_versions()
#' }
#' @export
get_versions <- memoise::memoise(get_versions_)
