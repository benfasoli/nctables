#!/usr/bin/env Rscript
# Ben Fasoli

library(data.table)
library(feather)
library(fst)
library(ggplot2)
library(nctables)

df <- as.data.frame(readRDS('data/wbb_aggregated.rds'))
df <- df[rep(seq_len(nrow(df)), each = 100),]


nctables_fun <- function() {
  nct_create(df, 'data/data.nc', 'Time')
  df_nct <- nct_read('data/data.nc')
}

rds_fun <- function() {
  saveRDS(df, 'data/data.rds')
  df_rds <- readRDS('data/data.rds')
}

fst_fun <- function() {
  write_fst(df, 'data/data.fst')
  df_fst <- read_fst('data/data.fst')
}

feather_fun <- function() {
  write_feather(df, 'data/data.feather')
  df_fst <- read_feather('data/data.feather')
}

csv_fun <- function() {
  write.csv(df, 'data/data.csv')
  df_csv <- read.csv('data/data.csv')
}

data.table_fun <- function() {
  fwrite(df, 'data/data_dt.csv')
  df_dt <- fread('data/data_dt.csv')
}


bench <- microbenchmark::microbenchmark(nctables = nctables_fun(),
                                        rds = rds_fun(),
                                        fst = fst_fun(),
                                        feather = feather_fun(),
                                        csv_builtin = csv_fun(),
                                        csv_data.table = data.table_fun(),
                                        times = 100)
sizes <- list(
  nctables = 'data/data.nc',
  rds = utils:::format.object_size(file.info('data/data.rds')$size, 'KB'),
  fst = utils:::format.object_size(file.info('data/data.fst')$size, 'KB'),
  feather = utils:::format.object_size(file.info('data/data.feather')$size, 'KB'),
  csv_builtin = utils:::format.object_size(file.info('data/data.csv')$size, 'KB'),
  csv_data.table = utils:::format.object_size(file.info('data/data_dt.csv')$size, 'KB')
)
sizes <- lapply(sizes, function(x) {
  size <- utils:::format.object_size(file.info(x)$size, 'KB')
  as.numeric(gsub(' .*$', '', size))
})
sizes <- tidyr::gather(as.data.frame(sizes), key, value)

# Use same factor levels for plot sorting
bench$expr <- factor(bench$expr, levels = sort(unique(as.character(bench$expr)), decreasing = T))
sizes$key <- factor(sizes$key, levels = sort(unique(as.character(sizes$key)), decreasing = T))

cowplot::plot_grid(
  nrow = 2,
  align = 'v',
  ggplot(data = bench, aes(x = expr, y = time * 1e-9, color = expr)) +
    geom_jitter(show.legend = F) +
    labs(x = NULL,
         y = 's',
         color = NULL,
         title = glue::glue('I/O: {format(nrow(df), big.mark = ",")} rows'),
         subtitle = 'Lower is better') +
    theme_classic(),
  ggplot(data = sizes, aes(x = key, y = value, color = key, fill = key)) +
    geom_bar(stat = 'identity', show.legend = F) +
    labs(x = NULL,
         y = 'KB',
         color = NULL,
         title = glue::glue('File Size: {format(object.size(df), "MB")} in memory'),
         subtitle = 'Lower is better') +
    theme_classic()
)
ggsave('benchmark.png', width = 7, height = 6, dpi = 200)
