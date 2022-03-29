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
      mapping <- tidyr::unnest(mapping, nci_code, keep_empty = keep_empty)
    }

    return(mapping)
  }

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
        dplyr::summarise(oncotree_code = list(oncotree_code))
    }

    return(mapping)
  }
