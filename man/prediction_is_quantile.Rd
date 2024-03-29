% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{prediction_is_quantile}
\alias{prediction_is_quantile}
\title{Check if predictions are quantile forecasts}
\usage{
prediction_is_quantile(data)
}
\arguments{
\item{data}{Data frame containing forecast predictions}
}
\value{
Logical indicating whether predictions are quantile forecasts
}
\description{
Internal helper function to check if a data frame contains
quantile forecast predictions. This is determined by checking if the
"quantile" column is present.
}
\keyword{internal}
