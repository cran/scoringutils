#' @title Interval Score
#'
#' @description
#' Proper Scoring Rule to score quantile predictions, following Gneiting
#' and Raftery (2007). Smaller values are better.
#'
#' The score is computed as
#'
#' \deqn{
#' score = (upper - lower) + 2/alpha * (lower - true_value) *
#' 1(true_values < lower) + 2/alpha * (true_value - upper) *
#' 1(true_value > upper)
#' }
#' where $1()$ is the indicator function and alpha is the decimal value that
#' indicates how much is outside the prediction interval.
#' To improve usability, the user is asked to provide an interval range in
#' percentage terms, i.e. interval_range = 90 (percent) for a 90 percent
#' prediction interval. Correspondingly, the user would have to provide the
#' 5\% and 95\% quantiles (the corresponding alpha would then be 0.1).
#' No specific distribution is assumed,
#' but the range has to be symmetric (i.e you can't use the 0.1 quantile
#' as the lower bound and the 0.7 quantile as the upper).
#'
#' The interval score is a proper scoring rule that scores a quantile forecast
#'
#' @param true_values A vector with the true observed values of size n
#' @param lower vector of size n with the lower quantile of the given range
#' @param upper vector of size n with the upper quantile of the given range
#' @param interval_range the range of the prediction intervals. i.e. if you're
#' forecasting the 0.05 and 0.95 quantile, the interval_range would be 90.
#' Can be either a single number or a vector of size n, if the range changes
#' for different forecasts to be scored. This corresponds to (100-alpha)/100
#' in Gneiting and Raftery (2007). Internally, the range will be transformed
#' to alpha.
#' @param weigh if TRUE, weigh the score by alpha / 4, so it can be averaged
#' into an interval score that, in the limit, corresponds to CRPS. Default:
#' FALSE.
#' @return vector with the scoring values
#' @examples
#' true_values <- rnorm(30, mean = 1:30)
#' interval_range = 90
#' alpha = (100 - interval_range) / 100
#' lower = qnorm(alpha/2, rnorm(30, mean = 1:30))
#' upper = qnorm((1- alpha/2), rnorm(30, mean = 1:30))
#'
#' interval_score(true_values = true_values,
#'                lower = lower,
#'                upper = upper,
#'                interval_range = interval_range)
#' @export
#' @references Strictly Proper Scoring Rules, Prediction,and Estimation,
#' Tilmann Gneiting and Adrian E. Raftery, 2007, Journal of the American
#' Statistical Association, Volume 102, 2007 - Issue 477
#'
#' Evaluating epidemic forecasts in an interval format,
#' Johannes Bracher, Evan L. Ray, Tilmann Gneiting and Nicholas G. Reich,
#' <arXiv:2005.12881v1>
#'


interval_score <- function(true_values,
                           lower,
                           upper,
                           interval_range = NULL,
                           weigh = FALSE) {

  if(is.null(interval_range)) {
    stop("must provide a range for your prediction interval")
  }

  alpha = (100 - interval_range) / 100

  score = (upper - lower) +
    2/alpha * (lower - true_values) * (true_values < lower) +
    2/alpha * (true_values - upper) * (true_values > upper)

  if (weigh) score <- score * alpha / 2

  return(score)
}

