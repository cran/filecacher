% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/with_cache.R
\name{with_cache}
\alias{with_cache}
\title{Cache via a file}
\usage{
with_cache(x, label, cache = NULL, type = NULL, force = FALSE)
}
\arguments{
\item{x}{The object to store in the cache. Must be compatible
with the cache type.}

\item{label}{A string to use as the name of the file to cache.}

\item{cache}{One of the following:
\itemize{
\item The path to an existing directory to use for caching.
If \code{NULL} (default) uses the current path, using \code{\link[here:here]{here::here()}}.
\item An existing cache object as generated by \code{\link[=file_cache]{file_cache()}}.
}}

\item{type}{A string describing the type of cache.
Must be \code{NULL} or one of 'rds', 'parquet', or 'csv'.
If \code{NULL} (default), uses 'rds'.}

\item{force}{If \code{TRUE}, forces evaluation even if the cache exists.}
}
\value{
The value of \code{x}.
}
\description{
If the cache exists, the object is retrieved from the cache.
Otherwise, it is evaluated and stored for subsequent retrieval.

Use \code{force=TRUE} to ensure the object is evaluated and stored
anew in the cache.

The object evaluated must be compatible with the cache type.
For example, a cache type of 'csv' or 'parquet' requires a
\code{data.frame} or similar type.
}
\examples{
# Create a temporary directory for the cache.
tf <- tempfile()
dir.create(tf)

# A dummy function that logs when it's called.
get_df <- function() {
  message("Getting df ...")
  return(mtcars)
}

# Use the resulting object in `with_cache()`.
# 1) The first time, the message is printed.
# 2) The second time, the object is pulled from the cache, with no message.
all.equal(with_cache(get_df(), "df", cache = tf), mtcars)
all.equal(with_cache(get_df(), "df", cache = tf), mtcars)

# `with_cache` is designed to be compatible with piping.
get_df() |>
  with_cache("df", cache = tf) |>
  all.equal(mtcars)


# Advanced: If desired, the `cachem` object methods can be used directly.
cache <- file_cache(tf)
cache$get("df") |> # Get objects previously cached using `with_cache`.
  all.equal(mtcars)
cache$set("df2", mtcars) # Set objects using `$set`.
cache$get("df2") |>
  all.equal(mtcars)

unlink(tf, recursive = TRUE)
}
