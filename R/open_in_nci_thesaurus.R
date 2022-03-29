#' @export
open_in_nci_thesaurus <- function(nci_code) {

  if (interactive()) {
    urls <-
      glue::glue("https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&ns=ncit&code={nci_code}")

    purrr::walk(urls, utils::browseURL)

    return(invisible(TRUE))
  } else {
    return(invisible(TRUE))
  }

}
