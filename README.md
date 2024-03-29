
<!-- README.md is generated from README.Rmd. Please edit that file -->

# filecacher

<!-- badges: start -->

[![](https://cranlogs.r-pkg.org/badges/filecacher)](https://cran.r-project.org/package=filecacher)
<!-- badges: end -->

The main functions in this package are:

1.  `with_cache()`: Caches the expression in a local file on disk, using
    `cachem::cache_disk()` as its backend. This can be comfortably added
    to a piped sequence and it handles evaluating if the element doesn’t
    already exist, or pulling from the cache if it does.

2.  `cached_read()`: A wrapper around a typical read function that
    caches the result and the file list info using
    `cachem::cache_disk()`. If the input file list info hasn’t changed
    (including date modified), the cache file will be read. This can
    save time if the original operation requires reading from many
    files, or involves lots of processing.

See examples below.

## Installation

You can install the released version of `filecacher` from
[CRAN](https://cran.r-project.org/package=filecacher) with:

``` r
install.packages("filecacher")
```

And the development version from
[GitHub](https://github.com/orgadish/filecacher):

``` r
if(!requireNamespace("remotes")) install.packages("remotes")

remotes::install_github("orgadish/filecacher")
```

## Example

``` r
# Example files: iris table split by species into three files.
iris_files_by_species <- list.files(
  system.file("extdata", package = "filecacher"),
  pattern = "_only[.]csv$",
  full.names = TRUE
)
basename(iris_files_by_species)
#> [1] "iris_setosa_only.csv"     "iris_versicolor_only.csv"
#> [3] "iris_virginica_only.csv"


# Create a temporary directory to run these examples.
tf <- withr::local_tempfile()
dir.create(tf)


something_that_takes_a_while <- function(x) {
  Sys.sleep(0.5)
  return(x)
}

# Example standard pipeline without caching:
#   1. Read using a vectorized `read.csv`.
#   2. Perform some custom processing that takes a while (currently using sleep as an example).
normal_pipeline <- function(files, cache_dir = NULL) {
  files |>
    filecacher::vectorize_reader(read.csv)() |>
    suppressMessages() |>
    something_that_takes_a_while()
}

# Same pipeline, using `cached_read` which caches the contents and the file info for checking later:
pipeline_using_cached_read <- function(files, cache_dir) {
  files |>
    filecacher::cached_read(
      label = "processed_data_using_cached_read",
      read_fn = normal_pipeline,
      cache = cache_dir,
      type = "parquet"
    )
}

# Alternate syntax, with `with_cache`. Using `with_cache` only checks that the cache file
# exists, without any information about the file list.
pipeline_using_with_cache <- function(files, cache_dir) {
  normal_pipeline(files) |>
    filecacher::with_cache(
      label = "processed_data_using_with_cache",
      cache = cache_dir,
      type = "parquet"
    )
}

# Time each pipeline when repeated 3 times:
time_pipeline <- function(pipeline_fn) {
  function_name <- as.character(match.call()[2])
  print(function_name)

  # Create a separate directory for the cache for this function.
  cache_dir <- tempfile(function_name, tmpdir = tf)
  dir.create(cache_dir)

  gc()

  for (i in 1:3) {
    print(system.time(pipeline_fn(iris_files_by_species, cache_dir)))
  }
}

time_pipeline(normal_pipeline)
#> [1] "normal_pipeline"
#>    user  system elapsed 
#>    0.06    0.03    0.60 
#>    user  system elapsed 
#>    0.00    0.02    0.52 
#>    user  system elapsed 
#>     0.0     0.0     0.5
time_pipeline(pipeline_using_cached_read)
#> [1] "pipeline_using_cached_read"
#>    user  system elapsed 
#>    0.59    0.18    1.30 
#>    user  system elapsed 
#>    0.03    0.00    0.03 
#>    user  system elapsed 
#>    0.00    0.02    0.01
time_pipeline(pipeline_using_with_cache)
#> [1] "pipeline_using_with_cache"
#>    user  system elapsed 
#>    0.01    0.02    0.53 
#>    user  system elapsed 
#>    0.01    0.01    0.03 
#>    user  system elapsed 
#>    0.00    0.02    0.02
```
