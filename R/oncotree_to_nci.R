#' Map OncoTree to NCIt codes
#'
#' This function maps OncoTree codes to  National Cancer Institute Thesaurus (NCIt) codes.
#'
#' @param oncotree_code OncoTree codes.
#' @param oncotree_version OncoTree database release version.
#' @param expand Whether to expand one-to-many mappings. If `TRUE`, one-to-many mappings are expanded into several rows in the output.
#' @param keep_empty OncoTree codes that do not map to NCI have the `nci_code` with `NA` if `keep_empty = TRUE`. Use `keep_empty = FALSE`, to remove the mapping (row) altogether from the output.
#'
#' @return A [tibble][tibble::tibble-package] of two variables: `oncotree_code` and `nci_code`.
#' @md
#' @examples
#' # Leave `oncotree_code` empty to return mappings for all OncoTree codes
#' oncotree_to_nci()
#'
#' # Map a few selected OncoTree codes
#' oncotree_to_nci(oncotree_code = c('PAOS', 'SCST', 'ITLPDGI', 'SRCCR'))
#'
#' # Use `expand` to make sure the column `nci_code` is a character vector and
#' # not a list-column. One-to-many mappings will result in more than row with
#' # `oncotree_code` values repeated.
#' oncotree_to_nci(oncotree_code = c('PAOS', 'SCST', 'ITLPDGI', 'SRCCR'), expand
#' = TRUE)
#'
#' # Use `keep_empty` to drop or keep one-to-none mappings
#' oncotree_to_nci(oncotree_code = c('PAOS', 'SCST', 'ITLPDGI', 'SRCCR'), expand
#' = TRUE, keep_empty = FALSE)
#'
#' @importFrom rlang .data
#' @export
oncotree_to_nci <-
  function(oncotree_code = NULL,
           oncotree_version = 'oncotree_latest_stable',
           expand = FALSE,
           keep_empty = TRUE) {
    ot2nci <- get_tumor_types(oncotree_version = oncotree_version) %>%
      dplyr::select(c('oncotree_code', 'nci_code'))

    if (is.null(oncotree_code)) {
      mapping <- ot2nci
    } else {
      oncotree_code_tbl <- tibble::tibble(oncotree_code = oncotree_code)

      mapping <-
        dplyr::left_join(oncotree_code_tbl, ot2nci, by = 'oncotree_code')
    }

    if (expand) {
      mapping <- tidyr::unnest(mapping, .data$nci_code, keep_empty = keep_empty)
    }

    return(mapping)
  }

#' Map NCI to OncoTree codes
#'
#' This function maps National Cancer Institute Thesaurus (NCIt) codes to OncoTree codes.
#'
#' @param nci_code NCI codes.
#' @param oncotree_version OncoTree database release version.
#' @param expand Whether to expand one-to-many mappings. If `TRUE`, one-to-many mappings are expanded into several rows in the output.
#'
#' @return A [tibble][tibble::tibble-package] of two variables: `nci_code` and `oncotree_code`.
#' @md
#'
#' @examples
#' # Leave `nci_code` empty to return mappings for all NCI codes
#' nci_to_oncotree()
#'
#' # Map a few selected OncoTree codes
#' nci_to_oncotree(nci_code = c('C8969', 'C4862', 'C9168', 'C7967'))
#'
#' # Use `expand` to make sure the column `oncotree_code` is a character vector
#' # and not a list-column. One-to-many mappings will result in more than row
#' # with `oncotree_code` values repeated.
#' nci_to_oncotree(nci_code = c('C8969', 'C4862', 'C9168', 'C7967'), expand =
#' TRUE)
#'
#' @importFrom rlang .data
#' @export
nci_to_oncotree <-
  function(nci_code = NULL,
           oncotree_version = 'oncotree_latest_stable',
           expand = FALSE) {
    nci2otc <-
      oncotree_to_nci(
        oncotree_version = oncotree_version,
        expand = TRUE,
        keep_empty = FALSE
      ) %>%
      dplyr::relocate(.data$nci_code, .data$oncotree_code)

    if (is.null(nci_code)) {
      mapping <- nci2otc
    } else {
      nci_code_tbl <- tibble::tibble(nci_code = nci_code)

      mapping <-
        dplyr::left_join(nci_code_tbl, nci2otc, by = 'nci_code')
    }

    if (!expand) {
      mapping <- dplyr::group_by(mapping, .data$nci_code) %>%
        dplyr::summarise(oncotree_code = list(.data$oncotree_code))
    }

    return(mapping)
  }
