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
