#' @keywords internal
read_ontology_mappings_ <-
  function(url = 'https://raw.githubusercontent.com/cBioPortal/oncotree/master/scripts/ontology_to_ontology_mapping_tool/ontology_mappings.txt', fix_names = TRUE, list_columns = TRUE) {

  tbl <- readr::read_tsv(file = url, col_types = 'cccccc', progress = FALSE)

  if(fix_names) {
    tbl <- dplyr::relocate(tbl,
                           oncotree_code = ONCOTREE_CODE,
                           nci_code = NCIT_CODE,
                           umls_code = UMLS_CODE,
                           icdo_topography_code = ICDO_TOPOGRAPHY_CODE,
                           icdo_morphology_code = ICDO_MORPHOLOGY_CODE,
                           hemeonc_code = HEMEONC_CODE)
  }

  if(list_columns) {
    tbl <- dplyr::mutate(tbl, dplyr::across(.fns = strsplit2, split = ','))
  }

  return(tbl)
}

#' @export
read_ontology_mappings <- memoise::memoise(read_ontology_mappings_)
