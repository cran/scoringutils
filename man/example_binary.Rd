% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{example_binary}
\alias{example_binary}
\title{Binary Forecast Example Data}
\format{
A data frame with 346 rows and 10 columns:
\describe{
\item{location}{the country for which a prediction was made}
\item{location_name}{name of the country for which a prediction was made}
\item{target_end_date}{the date for which a prediction was made}
\item{target_type}{the target to be predicted (cases or deaths)}
\item{true_value}{true observed values}
\item{forecast_date}{the date on which a prediction was made}
\item{model}{name of the model that generated the forecasts}
\item{horizon}{forecast horizon in weeks}
\item{prediction}{predicted value}
}
}
\source{
\url{https://github.com/european-modelling-hubs/covid19-forecast-hub-europe/commit/a42867b1ea152c57e25b04f9faa26cfd4bfd8fa6/} # nolint
}
\usage{
example_binary
}
\description{
A data set with binary predictions for COVID-19 cases and deaths constructed
from data submitted to the European Forecast Hub.
}
\details{
Predictions in the data set were constructed based on the continuous example
data by looking at the number of samples below the mean prediction.
The outcome was constructed as whether or not the actually
observed value was below or above that mean prediction.
This should not be understood as sound statistical practice, but rather
as a practical way to create an example data set.

The data was created using the script create-example-data.R in the inst/
folder (or the top level folder in a compiled package).
}
\keyword{datasets}
