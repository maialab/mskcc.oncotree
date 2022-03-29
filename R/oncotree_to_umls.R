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
        tidyr::unnest(mapping, umls_code, keep_empty = keep_empty)
    }

    return(mapping)
  }

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
        dplyr::summarise(oncotree_code = list(oncotree_code))
    }

    return(mapping)
  }
