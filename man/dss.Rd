% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scoringRules_wrappers.R
\name{dss}
\alias{dss}
\title{Dawid-Sebastiani Score}
\usage{
dss(true_values, predictions)
}
\arguments{
\item{true_values}{A vector with the true observed values of size n}

\item{predictions}{nxN matrix of predictive samples, n (number of rows) being
the number of data points and N (number of columns) the
number of Monte Carlo samples}
}
\value{
vector with scoring values
}
\description{
Wrapper around the \code{\link[scoringRules:scores_sample_univ]{dss_sample}}
function from the
\code{scoringRules} package.
}
\examples{
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
dss(true_values, predictions)
}
\references{
Alexander Jordan, Fabian Krüger, Sebastian Lerch, Evaluating Probabilistic
Forecasts withscoringRules, https://arxiv.org/pdf/1709.04743.pdf
}
