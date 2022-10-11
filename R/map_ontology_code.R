#' Map tumor types across ontologies
#'
#' @description
#' This function maps codes (identifiers) across tumor classification systems.
#' Use the arguments `from` and `to` to choose the source and target ontologies.
#' Available options are: `'oncotree_code'`, `'nci_code'`, `'umls_code'`,
#' `'icdo_topography_code'`, `'icdo_morphology_code'`, and `'hemeonc_code'`.
#'
#' Note that you can also use the functions [oncotree_to_nci()],
#' [nci_to_oncotree()], [oncotree_to_umls()] and [umls_to_oncotree()] to map
#' between OncoTree and NCIt systems. The difference is that these functions use
#' the OncoTree API, and the output can be made to depend on older versions of
#' OncoTree. `map_ontology_code()` relies on a static file provided by the
#' OncoTree team that is not as up to date as the data provided by the web API.
#' Nevetheless, the scope of the mappings provided by `map_ontology_code()` is
#' broader. The file used by `map_ontology_code()` can be directly imported into
#' R using the function `read_ontology_mappings()`.
#'
#' @param code A character vector with identifier codes of the `from` ontology that are meant to be mapped to the `to` ontology.
#' @param from The source ontology. One of: `'oncotree_code'`, `'nci_code'`, `'umls_code'`, `'icdo_topography_code'`, `'icdo_morphology_code'`, and `'hemeonc_code'`.
#' @param to The target ontology. One of: `'oncotree_code'`, `'nci_code'`, `'umls_code'`, `'icdo_topography_code'`, `'icdo_morphology_code'`, and `'hemeonc_code'`.
#' @param collapse A function that expects one argument, it will be the character vector of codes in the `to` variable, that are to be "collapsed". When the mapping is one-to-many, passing a collapsing function will allow you to make the mapping one-to-one. See examples.
#'
#' @return A [tibble][tibble::tibble-package] of two variables: first column is
#'   corresponds to the `from` variable and the second is the `to` variable.
#'
#' @source The mappings here provided are based on the file \url{https://github.com/cBioPortal/oncotree/blob/master/scripts/ontology_to_ontology_mapping_tool/ontology_mappings.txt}.
#'
#' @seealso [oncotree_to_nci()], [nci_to_oncotree()], [oncotree_to_umls()] and [umls_to_oncotree()].
#'
#' @examples
#' \dontrun{
#' # Omit the `code` argument to get all possible mappings. Note that
#' # one-to-many mappings will generate more than one row per `from` code.
#' map_ontology_code(from = 'oncotree_code', to = 'nci_code')
#'
#' # Simple example
#' map_ontology_code('MMB', from = 'oncotree_code', to = 'nci_code')
#'
#' # Some mappings are one-to-many, e.g. "SRCCR", which means repeated rows for
#' # the same input code.
#' map_ontology_code('SRCCR', from = 'oncotree_code', to = 'nci_code')
#'
#' # Using the `collapse` argument to "collapse" one-to-many mappings makes sure
#' # that the output has as many rows as the `from` vector.
#' map_ontology_code('SRCCR',
#'                   from = 'oncotree_code',
#'                   to = 'nci_code',
#'                   collapse = toString)
#'
#' map_ontology_code('SRCCR',
#'                   from = 'oncotree_code',
#'                   to = 'nci_code',
#'                   collapse = list)
#'
#' map_ontology_code(
#'   'SRCCR',
#'   from = 'oncotree_code',
#'   to = 'nci_code',
#'   collapse = \(x) paste(x, collapse = ' ')
#' )
#'
#' # `map_ontology_code()` is vectorized over `code`
#' map_ontology_code(
#'   c('AASTR', 'MDEP'),
#'   from = 'oncotree_code',
#'   to = 'nci_code'
#'   )
#'
#' # Map from ICDO topography to ICDO morphology codes
#' map_ontology_code(
#'   'C72.9',
#'   from = 'icdo_topography_code',
#'   to = 'icdo_morphology_code'
#'   )
#' }
#' @md
#' @importFrom rlang :=
#' @export
map_ontology_code <- function(code, from, to, collapse = NULL) {
  ontology_code_types <-
    c(
      'oncotree_code',
      'nci_code',
      'umls_code',
      'icdo_topography_code',
      'icdo_morphology_code',
      'hemeonc_code'
    )

  from <- match.arg(from, choices = ontology_code_types)
  to <- match.arg(to, choices = ontology_code_types)

  mappings <- read_ontology_mappings()
  from_to_mapping <- mappings[c(from, to)] %>%
    tidyr::unnest(cols = tidyr::everything())

  # If no codes are passed, then let return the mappings for all codes.
  if(missing(code)) {
    from_tbl <- from_to_mapping[from]
  } else {
    from_tbl <- tibble::tibble(code)
    colnames(from_tbl) <- from
  }

  my_mapping <- dplyr::left_join(from_tbl, from_to_mapping, by = from)

  if(!is.null(collapse)) {
    my_mapping <-
      my_mapping %>%
      dplyr::group_by(.data[[from]]) %>%
      dplyr::summarise({{ to }} := collapse(.data[[to]]))
  }

  my_mapping <-
    dplyr::filter(my_mapping, dplyr::if_any(dplyr::everything(), ~ !is.na(.)))

  return(my_mapping)
}
