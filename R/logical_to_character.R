#' Converts a logical vector to character
#'
#' This function converts a logical vector to a character vector allowing to
#' control the case and even to convert to integer 0 or 1 if desired.
#'
#' @param x A logical vector.
#' @param format Controls how the text is generated.
#'
#' @return A character vector.
#'
#' @keywords internal
logical_to_character <- function(x, format = c('lowercase', 'uppercase', 'titlecase', 'integer')) {

  if(!is.logical(x)) stop('`x` must be a logical vector')

  format <- match.arg(format)

  switch (format,
          lowercase = ifelse(x, 'true', 'false'),
          uppercase = ifelse(x, 'TRUE', 'FALSE'),
          titlecase = ifelse(x, 'True', 'False'),
          integer = ifelse(x, '1', '0')
  )

}
