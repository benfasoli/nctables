#' Add nctables type mapping to options interface
#' @author Ben Fasoli
#'
#' @param libname unused but retained for historical reasons
#' @param pkgname unused but retained for historical reasons
.onLoad <- function(libname, pkgname) {
  options(
    nctables_type_map = list(
      'character' = 'char',
      'Date' = 'date',
      'factor' = 'char',
      'integer' = 'integer',
      'logical' = 'bool',
      'numeric' = 'float',
      'POSIXct' = 'datetime'
    ),
    nctables_prec_map = list(
      'character' = 'char',
      'Date' = 'float',
      'factor' = 'char',
      'integer' = 'integer',
      'logical' = 'integer',
      'numeric' = 'float',
      'POSIXct' = 'float'
    )
  )

  invisible()
}

#' Remove nctables type mapping from options interface
#' @author Ben Fasoli
#'
#' @param libname unused but retained for historical reasons
#' @param pkgname unused but retained for historical reasons
.onUnload <- function(libname, pkgname) {
  options(nctables_type_map = NULL,
          nctables_prec_map = NULL)
}
