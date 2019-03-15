#' Serializes data.frame to NetCDF file
#'
#' @author Ben Fasoli
#'
#' @param df data.frame to be written
#' @param filename character string specifying output file ending in `.nc`
#' @param dims character vector specifying at least one column as a dimension
#' @param longnames optional long names to include as dimension or variable
#'   attributes, formatted as a named list or vector where keys match column
#'   names in `df` and values specify the desired `long_name` NetCDF attribute
#' @param units optional units to include as dimension or variable attributes,
#'   using the same format as `longnames`, except POSIXct columns will override
#'   a user specified units field with "seconds since 1970-01-01T00:00:00Z" for
#'   POSIX compliance
#'
#' @import ncdf4
#' @export

nct_create <- function(df, filename, dims, longnames = NA, units = NA) {

  cols <- colnames(df)

  if (is.na(longnames[1])) {
    longnames <- cols
    names(longnames) <- cols
  }

  if (is.na(units[1])) {
    units <- rep('', times = length(cols))
    names(units) <- cols
  }

  if (file.exists(filename)) {
    unlink(filename)
  }

  if (!all(dims %in% colnames(df))) {
    stop('Dimensions not in data.frame columns.')
  }

  if (!all(colnames(df) %in% names(longnames))) {
    stop('Must provide longnames for all columns in data.frame.')
  }

  if (!all(colnames(df) %in% names(units))) {
    stop('Must provide units for all columns in data.frame.')
  }

  vars <- setdiff(cols, dims)
  metas <- lapply(df, nct_serialize)

  nc_dims <- list()
  for (dim in dims) {
    meta <- metas[[dim]]
    unit <- ifelse(is.na(meta$units), units[[dim]], meta$units)
    nc_dims[[dim]] <- ncdf4::ncdim_def(calendar = meta$calendar,
                                       longname = longnames[[dim]],
                                       name = dim,
                                       units = unit,
                                       unlim = T,
                                       vals = meta$vals)
  }

  nc_vars <- list()
  for (var in vars) {
    meta <- metas[[var]]
    unit <- ifelse(is.na(meta$units), units[[var]], meta$units)
    nc_vars[[var]] <- ncdf4::ncvar_def(compression = 9,
                                       dim = nc_dims,
                                       longname = longnames[[var]],
                                       name = var,
                                       prec = meta$prec,
                                       units = unit)
  }

  nc <- ncdf4::nc_create(filename, vars = nc_vars, force_v4 = T)

  for (var in vars) {
    meta <- metas[[var]]
    ncdf4::ncvar_put(nc = nc,
                     varid = var,
                     vals = meta$vals)
    ncdf4::ncatt_put(nc = nc,
                     varid = var,
                     attname = 'nct_type',
                     attval = meta$type,
                     prec = 'text')
  }

  for (dim in dims) {
    meta <- metas[[dim]]
    ncdf4::ncatt_put(nc = nc,
                     varid = dim,
                     attname = 'nct_type',
                     attval = meta$type,
                     prec = 'text')
  }

  ncdf4::nc_close(nc)
}
