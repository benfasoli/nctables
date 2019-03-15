#' Coerce object into nctables compatible format
#'
#' @author Ben Fasoli
#'
#' @param x object to serialize, typically a column extracted from a data.frame

nct_serialize <- function(x) {
  type <- class(x)[1]

  type_map <- getOption('nctables_type_map')
  prec_map <- getOption('nctables_prec_map')

  nct_type <- type_map[[type]]
  nct_prec <- prec_map[[type]]

  calendar <- ifelse(nct_type %in% c('date', 'datetime'), 'standard', NA)
  units <- ifelse(nct_type %in% c('date', 'datetime'),
                  'seconds since 1970-01-01T00:00:00Z', NA)

  vals <- x
  class(vals) <- names(type_map)[type_map == nct_prec]

  list(calendar = calendar,
       prec = nct_prec,
       units = units,
       type = nct_type,
       vals = vals)
}
