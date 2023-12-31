% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interpret_type.R
\name{interpret_cache_type}
\alias{interpret_cache_type}
\title{Generate cache parameters from preexisting shorthand types.}
\usage{
interpret_cache_type(type, ext_prefix = "cache_")
}
\arguments{
\item{type}{A string describing the type of cache.
Must be \code{NULL} or one of 'rds', 'parquet', or 'csv'.
If \code{NULL} (default), uses 'rds'.}

\item{ext_prefix}{The prefix to use with the file extension,
e.g. "cache_csv", instead of "csv".}
}
\value{
List of \code{read_fn}, \code{write_fn}, and \code{extension} for use with
\code{\link[cachem:cache_disk]{cachem::cache_disk()}}.
}
\description{
Generate cache parameters from preexisting shorthand types.
}
