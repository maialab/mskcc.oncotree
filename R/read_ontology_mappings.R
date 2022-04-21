ontology_mapping_url <- function() {
  paste0(
    'https://raw.githubusercontent.com',
    '/cBioPortal/oncotree/master/scripts/',
    'ontology_to_ontology_mapping_tool/ontology_mappings.txt'
  )
}

read_ontology_mappings_ <-
  function(url = ontology_mapping_url(), fix_names = TRUE, list_columns = TRUE) {

  tbl <- readr::read_tsv(file = url, col_types = 'cccccc', progress = FALSE)

  if(fix_names) {
    tbl <- dplyr::relocate(tbl,
                           oncotree_code = .data$ONCOTREE_CODE,
                           nci_code = .data$NCIT_CODE,
                           umls_code = .data$UMLS_CODE,
                           icdo_topography_code = .data$ICDO_TOPOGRAPHY_CODE,
                           icdo_morphology_code = .data$ICDO_MORPHOLOGY_CODE,
                           hemeonc_code = .data$HEMEONC_CODE)
  }

  if(list_columns) {
    tbl <- dplyr::mutate(tbl, dplyr::across(.fns = strsplit2, split = ','))
  }

  return(tbl)
}

#' Reads ontology_mappings.txt from OncoTree's GitHub repository
#'
#' Reads `ontology_mappings.txt` from OncoTree's GitHub repository and returns
#' its contents as a tibble.
#'
#' @param url URL of `ontology_mappings.txt`.
#' @param fix_names Whether to convert column names to lowercase, snakecase.
#' @param list_columns Whether to return multi-value variables as list-columns.
#'
#' @return A [tibble][tibble::tibble-package] of six variables:
#' \describe{
#' \item{`oncotree_code`}{OncoTree code.}
#' \item{`nci_code`}{National Cancer Institute (NCI) Thesaurus code.}
#' \item{`umls_code`}{Unified Medical Language System (UMLS) code.}
#' \item{`icdo_topography_code`}{ICD-O topography code.}
#' \item{`icdo_morphology_code`}{ICD-O morphology code.}
#' \item{`hemeonc_code`}{HemeOnc code.}
#' }
#'
#' @examples
#' # Import ontology_mappings.txt as tibble
#' read_ontology_mappings()
#'
#' # Do not convert column names, i.e. keep them as originally in the file
#' read_ontology_mappings(fix_names = FALSE)
#'
#' # Keep multi-value columns as originally, i.e. as comma-separated values
#' read_ontology_mappings(list_columns = FALSE)
#'
#' @importFrom rlang .data
#' @keywords internal
#' @export
read_ontology_mappings <- memoise::memoise(read_ontology_mappings_)
