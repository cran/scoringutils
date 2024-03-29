% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/input-check-helpers.R
\name{check_not_null}
\alias{check_not_null}
\title{Check Variable is not NULL}
\usage{
check_not_null(...)
}
\arguments{
\item{...}{The variables to check}
}
\value{
The function returns \code{NULL}, but throws an error if the variable is
missing.
}
\description{
Check whether a certain variable is not \code{NULL} and return the name of that
variable and the function call where the variable is missing. This function
is a helper function that should only be called within other functions
}
\keyword{internal}
