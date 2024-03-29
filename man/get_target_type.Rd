% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get_target_type}
\alias{get_target_type}
\title{Get type of the target true values of a forecast}
\usage{
get_target_type(data)
}
\arguments{
\item{data}{A data.frame or data.table with the predictions and observations.
For scoring using \code{\link[=score]{score()}}, the following columns need to be present:
\itemize{
\item \code{true_value} - the true observed values
\item \code{prediction} - predictions or predictive samples for one
true value. (You only don't need to provide a prediction column if
you want to score quantile forecasts in a wide range format.)}
For scoring integer and continuous forecasts a \code{sample} column is needed:
\itemize{
\item \code{sample} - an index to identify the predictive samples in the
prediction column generated by one model for one true value. Only
necessary for continuous and integer forecasts, not for
binary predictions.}
For scoring predictions in a quantile-format forecast you should provide
a column called \code{quantile}:
\itemize{
\item \code{quantile}: quantile to which the prediction corresponds
}

In addition a \code{model} column is suggested and if not present this will be
flagged and added to the input data with all forecasts assigned as an
"unspecified model").

You can check the format of your data using \code{\link[=check_forecasts]{check_forecasts()}} and there
are examples for each format (\link{example_quantile}, \link{example_continuous},
\link{example_integer}, and \link{example_binary}).}
}
\value{
Character vector of length one with either "binary", "integer", or
"continuous"
}
\description{
Internal helper function to get the type of the target
true values of a forecast. That is inferred based on the which columns
are present in the data.
}
\keyword{internal}
