# Returns a list or a character vector (if each element contains only one string)
strsplit2 <- function(x, split, fixed = FALSE, perl = FALSE, useBytes = FALSE) {

  x_split <- strsplit(x = x, split = split, fixed = fixed, perl = perl, useBytes = useBytes)

  if(all(sapply(x_split, length) < 2)) x_split <- unlist(x_split)

  return(x_split)
}
