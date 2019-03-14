#' Coerce object into nctables compatible format
#'
#' @author Ben Fasoli
#'
#' @param x object to serialize, typically a column extracted from a data.frame

nct_serialize <- function(x) {
  type <- class(x)[1]
  calendar <- switch(type,
                     'POSIXct' = 'standard',
                     'Date' = 'standard',
                     NA)
  prec <- switch(type,
                 'POSIXct' = 'float',
                 'Date' = 'float',
                 'numeric' = 'float',
                 'integer' = 'integer',
                 'character' = 'char',
                 'float')
  units <- switch(type,
                  'POSIXct' = 'seconds since 1970-01-01T00:00:00Z',
                  'Date' = 'seconds since 1970-01-01T00:00:00Z',
                  NA)
  vals <- switch(type,
                 'POSIXct' = as.numeric(x),
                 'Date' = as.numeric(x),
                 'factor' = as.character(x),
                 x)
  list(calendar = calendar,
       prec = prec,
       units = units,
       type = type,
       vals = vals)
}
