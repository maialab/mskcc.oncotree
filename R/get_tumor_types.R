#' @importFrom rlang .data
get_tumor_types_ <- function(oncotree_version = 'oncotree_latest_stable') {

  # TODO: `children` object is not parsed because at the time of this writing
  # this object is always empty, so it is impossible to learn its contents.

  resp <- get('/tumorTypes', version = oncotree_version)

  tbl_json_1 <-
    resp %>%
    tidyjson::gather_array()

  umls_code <-
    tbl_json_1 %>%
    tidyjson::spread_values(code = tidyjson::jstring('code')) %>%
    tidyjson::enter_object('externalReferences') %>%
    tidyjson::enter_object('UMLS') %>%
    tidyjson::gather_array('dummy') %>%
    tidyjson::append_values_string('umls_code') %>%
    tidyjson::as_tibble() %>%
    dplyr::group_by(.data$code) %>%
    dplyr::summarise(umls_code = list(.data$umls_code))

    # tidyjson::append_values_string('UMLS') %>%
    # tidyjson::as_tibble() %>%
    # dplyr::select(-c('document.id', 'array.index'))

  nci_code <-
    tbl_json_1 %>%
    tidyjson::spread_values(code = tidyjson::jstring('code')) %>%
    tidyjson::enter_object('externalReferences') %>%
    tidyjson::enter_object('NCI') %>%
    tidyjson::gather_array('dummy') %>%
    tidyjson::append_values_string('nci_code') %>%
    tidyjson::as_tibble() %>%
    dplyr::group_by(.data$code) %>%
    dplyr::summarise(nci_code = list(.data$nci_code))

  history <-
    tbl_json_1 %>%
    tidyjson::spread_values(code = tidyjson::jstring('code')) %>%
    tidyjson::enter_object('history') %>%
    tidyjson::gather_array('dummy') %>%
    tidyjson::append_values_string('history') %>%
    tidyjson::as_tibble() %>%
    dplyr::group_by(.data$code) %>%
    dplyr::summarise(history = list(.data$history))

  revocations <-
    tbl_json_1 %>%
    tidyjson::spread_values(code = tidyjson::jstring('code')) %>%
    tidyjson::enter_object('revocations') %>%
    tidyjson::gather_array('dummy') %>%
    tidyjson::append_values_string('revocations') %>%
    tidyjson::as_tibble() %>%
    dplyr::group_by(.data$code) %>%
    dplyr::summarise(revocations = list(.data$revocations))

  precursors <-
    tbl_json_1 %>%
    tidyjson::spread_values(code = tidyjson::jstring('code')) %>%
    tidyjson::enter_object('precursors') %>%
    tidyjson::gather_array('dummy') %>%
    tidyjson::append_values_string('precursors') %>%
    tidyjson::as_tibble() %>%
    dplyr::group_by(.data$code) %>%
    dplyr::summarise(precursors = list(.data$precursors))

  tumor_types <-
    tbl_json_1 %>%
    tidyjson::spread_all() %>%
    tidyjson::as_tibble() %>%
    dplyr::select(-c('document.id', 'array.index')) %>%
    dplyr::rename(main_type = .data$mainType) %>%
    dplyr::mutate(level = as.integer(.data$level))

  tumor_types <-
    dplyr::left_join(tumor_types, umls_code, by = 'code') %>%
    dplyr::left_join(nci_code, by = 'code') %>%
    dplyr::left_join(history, by = 'code') %>%
    dplyr::left_join(revocations, by = 'code') %>%
    dplyr::left_join(precursors, by = 'code')

  tumor_types <-
  tumor_types %>%
    dplyr::rename(oncotree_code = .data$code,
                  oncotree_name = .data$name,
                  oncotree_main_type = .data$main_type)

  tumor_types <-
    tumor_types %>%
    dplyr::relocate(.data$oncotree_code,
                    .data$oncotree_name,
                    .data$oncotree_main_type,
                    .data$tissue,
                    .data$level,
                    .data$parent,
                    .data$umls_code,
                    .data$nci_code,
                    .data$history,
                    .data$revocations,
                    .data$precursors,
                    .data$color)

  tumor_types <-
    tumor_types %>%
    tibble::add_column(oncotree_version = oncotree_version, .before = 1L)

  return(tumor_types)
}

#' Get tumor types
#'
#' Get tumor types according to OncoTree's ontology.
#'
#' @param oncotree_version OncoTree version. Check available options with [get_versions()].
#'
#' @return A [tibble][tibble::tibble-package] of 13 variables:
#' \describe{
#' \item{`oncotree_version`}{OncoTree tumor classification system version.}
#' \item{`oncotree_code`}{Tumor type code: a unique identifier for a tumor type within the classification system of the OncoTree.}
#' \item{`oncotree_name`}{Tumor type name: a brief description of the tumor type.}
#' \item{`oncotree_main_type`}{Tumor main type: a category under which the tumor type can be grouped.}
#' \item{`tissue`}{Tissue associated with the tumor type.}
#' \item{`level`}{OncoTree is a hierachical classification system with 5 levels. At the root level (level 0) there is the single `"TISSUE"` tumor type. At level 1, there are 32 tissue sites, e.g., `"BREAST"`.}
#' \item{`parent`}{The `parent` is the parent `oncotree_code` for this tumor type.}
#' \item{`umls_code`}{The corresponding tumor type identifier(s) in the Unified Medical Language System (UMLS).}
#' \item{`nci_code`}{The corresponding tumor type identifier(s) in the National Cancer Institute (NCI) Thesaurus.}
#' \item{`history`}{Previous tumor type codes (from previous OncoTree versions) used to identify this tumor type.}
#' \item{`revocations`}{TODO.}
#' \item{`precursors`}{TODO.}
#' \item{`color`}{Color associated with the tumor type.}
#' }
#' @examples
#' get_tumor_types()
#'
#' @md
#' @importFrom rlang .data
#' @export
get_tumor_types <- memoise::memoise(get_tumor_types_)
