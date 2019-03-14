# nctables

Minimal tools lightning fast data frame serialization in R built on NetCDF4 for language interoperability.

## Installation

You can install the development version of nctables from GitHub using `devtools`.

``` r
install.packages('devtools')
devtools::install_github('benfasoli/nctables')
```

## Example

Let's grab some free timeseries data from the [Alpha Vantage API](https://www.alphavantage.co/documentation/).

``` r
df <- read.csv(paste0('https://www.alphavantage.co/query',
                      '?function=TIME_SERIES_INTRADAY',
                      '&symbol=MSFT',
                      '&interval=5min',
                      '&apikey=demo',
                      '&datatype=csv'),
               stringsAsFactors = F)
df$timestamp <- as.POSIXct(df$timestamp, tz = 'US/Eastern')
attributes(df$timestamp)$tzone <- 'UTC'
str(df)
# 'data.frame':	100 obs. of  6 variables:
#  $ timestamp: POSIXct, format: "2019-03-14 20:00:00" "2019-03-14 19:55:00" "2019-03-14 19:50:00" ...
#  $ open     : num  115 115 115 115 115 ...
#  $ high     : num  115 115 115 115 115 ...
#  $ low      : num  115 115 115 115 115 ...
#  $ close    : num  115 115 115 115 115 ...
#  $ volume   : int  1940399 636311 281969 295167 203164 194081 192107 151209 177943 111024 ...
```

Using the `timestamp` column as our only dimension, serialize the data to a NetCDF file and read the result back into a data frame.

```r
nct_create(df, filename = 'filename.nc', dims = 'timestamp')
df_nct <- nct_read('filename.nc')
str(df_nct)
# 'data.frame':	100 obs. of  6 variables:
#  $ timestamp: POSIXct, format: "2019-03-14 20:00:00" "2019-03-14 19:55:00" "2019-03-14 19:50:00" ...
#  $ open     : num  115 115 115 115 115 ...
#  $ high     : num  115 115 115 115 115 ...
#  $ low      : num  115 115 115 115 115 ...
#  $ close    : num  115 115 115 115 115 ...
#  $ volume   : int  1940399 636311 281969 295167 203164 194081 192107 151209 177943 111024 ...
```

Inspecting the output file more closely using the `ncdump` command line utility -

```bash
> ncdump -h filename.nc
# netcdf filename {
# dimensions:
# 	timestamp = UNLIMITED ; // (100 currently)
# variables:
# 	double timestamp(timestamp) ;
# 		timestamp:units = "seconds since 1970-01-01T00:00:00Z" ;
# 		timestamp:long_name = "timestamp" ;
# 		timestamp:calendar = "standard" ;
# 		timestamp:nct_type = "POSIXct" ;
# 	float open(timestamp) ;
# 		open:_FillValue = -99999.f ;
# 		open:nct_type = "numeric" ;
# 	float high(timestamp) ;
# 		high:_FillValue = -99999.f ;
# 		high:nct_type = "numeric" ;
# 	float low(timestamp) ;
# 		low:_FillValue = -99999.f ;
# 		low:nct_type = "numeric" ;
# 	float close(timestamp) ;
# 		close:_FillValue = -99999.f ;
# 		close:nct_type = "numeric" ;
# 	int volume(timestamp) ;
# 		volume:_FillValue = -99999 ;
# 		volume:nct_type = "integer" ;
# }
```

### Fully qualified metadata

The above example works well for datasets that don't require much documentation but NetCDF provides dedicated fields for metadata that can explicitly document variable descriptions and units. These fields are required for conformance with the [NetCDF CF Metadata Convention](http://cfconventions.org/) and can be specified when creating a new `nctables` file.

```r
nct_create(df,
           filename = 'filename.nc',
           dims = 'timestamp',
           longnames = list(timestamp = 'inverval end time',
                            open = 'inverval open price',
                            high = 'inverval high price',
                            low = 'inverval low price',
                            close = 'interval close price',
                            volume = 'shares traded'),
           units = list(timestamp = 'seconds since 1970-01-01T00:00:00Z',
                        open = 'USD',
                        high = 'USD',
                        low = 'USD',
                        close = 'USD',
                        volume = 'shares'))
```

```bash
> ncdump -h filename.nc
# netcdf filename {
# dimensions:
# 	timestamp = UNLIMITED ; // (100 currently)
# variables:
# 	double timestamp(timestamp) ;
# 		timestamp:units = "seconds since 1970-01-01T00:00:00Z" ;
# 		timestamp:long_name = "inverval end time" ;
# 		timestamp:calendar = "standard" ;
# 		timestamp:nct_type = "POSIXct" ;
# 	float open(timestamp) ;
# 		open:units = "USD" ;
# 		open:_FillValue = -99999.f ;
# 		open:long_name = "inverval open price" ;
# 		open:nct_type = "numeric" ;
# 	float high(timestamp) ;
# 		high:units = "USD" ;
# 		high:_FillValue = -99999.f ;
# 		high:long_name = "inverval high price" ;
# 		high:nct_type = "numeric" ;
# 	float low(timestamp) ;
# 		low:units = "USD" ;
# 		low:_FillValue = -99999.f ;
# 		low:long_name = "inverval low price" ;
# 		low:nct_type = "numeric" ;
# 	float close(timestamp) ;
# 		close:units = "USD" ;
# 		close:_FillValue = -99999.f ;
# 		close:long_name = "interval close price" ;
# 		close:nct_type = "numeric" ;
# 	int volume(timestamp) ;
# 		volume:units = "shares" ;
# 		volume:_FillValue = -99999 ;
# 		volume:long_name = "shares traded" ;
# 		volume:nct_type = "integer" ;
# }
```

## Benchmarks

With ~15,000 rows, 

<p align="center">
  <img src="man/figures/benchmark.png" width=600 alt="Benchmarks" />
</p>

and with ~150,000 rows,

<p align="center">
  <img src="man/figures/benchmark-10x.png" width=600 alt="10x Data Benchmarks" />
</p>
