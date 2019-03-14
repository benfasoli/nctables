#' Deserialize object from nctables format
#'
#' @author Ben Fasoli
#'
#' @param nc an object of class `ncdf4` as returned by `nc_open`
#' @param var string indicating variable to deserialize
#'
#' @import ncdf4

nct_deserialize <- function(nc, var) {
  type_att <- ncdf4::ncatt_get(nc = nc,
                               varid = var,
                               attname = 'nct_type')

  if (!type_att$hasatt) {
    stop('File was not created with nctables::nct_create.')
  }

  type <- type_att$value

  vals <- ncdf4::ncvar_get(nc, var)

  class(vals) <- type
  attributes(vals) <- switch(type,
                             'POSIXct' = list(class = c('POSIXct', 'POSIXt'),
                                              tzone = 'UTC'),
                             'Date' = list(class = 'Date', tzone = 'UTC'),
                             list(class = type))

  vals
}
