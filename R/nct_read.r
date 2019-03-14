#' Reads nct formatted NetCDF file to a data.frame
#'
#' @author Ben Fasoli
#'
#' @param filename character string specifying output file ending in `.nc`
#'
#' @import ncdf4
#' @export

nct_read <- function(filename) {
  nc <- ncdf4::nc_open(filename)

  cols <- list()
  for (dim in nc$dim) {
    name <- dim$name
    cols[[name]] <- nct_deserialize(nc, name)
  }

  for (var in names(nc$var)) {
    cols[[var]] <- nct_deserialize(nc, var)
  }

  as.data.frame(cols, stringsAsFactors = F)
}
