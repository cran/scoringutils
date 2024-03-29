% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/input-check-helpers.R
\name{check_equal_length}
\alias{check_equal_length}
\title{Check Length}
\usage{
check_equal_length(..., one_allowed = TRUE)
}
\arguments{
\item{...}{The variables to check}

\item{one_allowed}{logical, allow arguments of length one that can be
recycled}
}
\value{
The function returns \code{NULL}, but throws an error if variable lengths
differ
}
\description{
Check whether variables all have the same length
}
\keyword{internal}
