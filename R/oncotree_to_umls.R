#' Map OncoTree to UMLS codes
#'
#' This function maps OncoTree codes to Unified Medical Language System (UMLS) codes.
#'
#' @param oncotree_code OncoTree codes.
#' @param oncotree_version OncoTree database release version.
#' @param expand Whether to expand one-to-many mappings. If `TRUE`, one-to-many mappings are expanded into several rows in the output.
#' @param keep_empty OncoTree codes that do not map to UMLS have the `umls_code` with `NA` if `keep_empty = TRUE`. Use `keep_empty = FALSE`, to remove the mapping (row) altogether from the output.
#'
#' @return A [tibble][tibble::tibble-package] of two variables: `oncotree_code` and `umls_code`.
#' @md
#'
#' @examples
#' # Leave `oncotree_code` empty to return mappings for all OncoTree codes
#' oncotree_to_umls()
#'
#' # Map a few selected OncoTree codes
#' oncotree_to_umls(oncotree_code = c('PAOS', 'SCST', 'ITLPDGI', 'SRCCR'))
#'
#' # Use `expand` to make sure the column `umls_code` is a character vector and
#' # not a list-column. One-to-many mappings will result in more than row with
#' # `oncotree_code` values repeated.
#' oncotree_to_umls(oncotree_code = c('PAOS', 'SCST', 'ITLPDGI', 'SRCCR'),
#'   expand = TRUE)
#'
#' # Use `keep_empty` to drop or keep one-to-none mappings
#' oncotree_to_umls(oncotree_code = c('PAOS', 'SCST', 'ITLPDGI', 'SRCCR'),
#'   expand = TRUE, keep_empty = FALSE)
#'
#' @importFrom rlang .data
#' @export
oncotree_to_umls <-
  function(oncotree_code = NULL,
           oncotree_version = 'oncotree_latest_stable',
           expand = FALSE,
           keep_empty = TRUE) {
    ot2umls <- get_tumor_types(oncotree_version = oncotree_version) %>%
      dplyr::select(c('oncotree_code', 'umls_code'))

    if (is.null(oncotree_code)) {
      mapping <- ot2umls
    } else {
      oncotree_code_tbl <- tibble::tibble(oncotree_code = oncotree_code)

      mapping <-
        dplyr::left_join(oncotree_code_tbl, ot2umls, by = 'oncotree_code')
    }

    if (expand) {
      mapping <-
        tidyr::unnest(mapping, .data$umls_code, keep_empty = keep_empty)
    }

    return(mapping)
  }


#' Map UMLS to OncoTree codes
#'
#' This function maps Unified Medical Language System (UMLS) codes to OncoTree codes.
#'
#' @param umls_code UMLS codes.
#' @param oncotree_version OncoTree database release version.
#' @param expand Whether to expand one-to-many mappings. If `TRUE`, one-to-many mappings are expanded into several rows in the output.
#'
#' @return A [tibble][tibble::tibble-package] of two variables: `umls_code` and `oncotree_code`.
#' @md
#'
#' @examples
#' # Leave `umls_code` empty to return mappings for all UMLS codes
#' umls_to_oncotree()
#'
#' # Map a few selected OncoTree codes
#' umls_to_oncotree(umls_code = c('C0206642', 'C0600113', 'C0279654', 'C1707436'))
#'
#' # Use `expand` to make sure the column `oncotree_code` is a character vector and
#' # not a list-column. One-to-many mappings will result in more than row with
#' # `oncotree_code` values repeated.
#' umls_to_oncotree(umls_code = c('C0206642', 'C0600113', 'C0279654', 'C1707436'), expand = TRUE)
#'
#' @importFrom rlang .data
#' @export
umls_to_oncotree <-
  function(umls_code = NULL,
           oncotree_version = 'oncotree_latest_stable',
           expand = FALSE) {
    umls2otc <-
      oncotree_to_umls(
        oncotree_version = oncotree_version,
        expand = TRUE,
        keep_empty = FALSE
      ) %>%
      dplyr::relocate(.data$umls_code, .data$oncotree_code)

    if (is.null(umls_code)) {
      mapping <- umls2otc
    } else {
      umls_code_tbl <- tibble::tibble(umls_code = umls_code)

      mapping <-
        dplyr::left_join(umls_code_tbl, umls2otc, by = 'umls_code')
    }

    if (!expand) {
      mapping <- dplyr::group_by(mapping, .data$umls_code) %>%
        dplyr::summarise(oncotree_code = list(.data$oncotree_code))
    }

    return(mapping)
  }
