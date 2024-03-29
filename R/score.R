#' @title Evaluate forecasts
#'
#' @description This function allows automatic scoring of forecasts using a
#' range of metrics. For most users it will be the workhorse for
#' scoring forecasts as it wraps the lower level functions package functions.
#' However, these functions are also available if you wish to make use of them
#' independently.
#'
#' A range of forecasts formats are supported, including quantile-based,
#' sample-based, binary forecasts. Prior to scoring, users may wish to make use
#' of [check_forecasts()] to ensure that the input data is in a supported
#' format though this will also be run internally by [score()]. Examples for
#' each format are also provided (see the documentation for `data` below or in
#' [check_forecasts()]).
#'
#' Each format has a set of required columns (see below). Additional columns may
#' be present to indicate a grouping of forecasts. For example, we could have
#' forecasts made by different models in various locations at different time
#' points, each for several weeks into the future. It is important, that there
#' are only columns present which are relevant in order to group forecasts.
#' A combination of different columns should uniquely define the
#' *unit of a single forecast*, meaning that a single forecast is defined by the
#' values in the other columns. Adding additional unrelated columns may alter
#' results.
#'
#' To obtain a quick overview of the currently supported evaluation metrics,
#' have a look at the [metrics] data included in the package. The column
#' `metrics$Name` gives an overview of all available metric names that can be
#' computed. If interested in an unsupported metric please open a [feature
#' request](https://github.com/epiforecasts/scoringutils/issues) or consider
#' contributing a pull request.
#'
#' For additional help and examples, check out the [Getting Started
#' Vignette](https://epiforecasts.io/scoringutils/articles/scoringutils.html)
#' as well as the paper [Evaluating Forecasts with scoringutils in
#' R](https://arxiv.org/abs/2205.07090).
#'
#' @param data A data.frame or data.table with the predictions and observations.
#' For scoring using [score()], the following columns need to be present:
#' \itemize{
#'   \item `true_value` - the true observed values
#'   \item `prediction` - predictions or predictive samples for one
#'   true value. (You only don't need to provide a prediction column if
#'   you want to score quantile forecasts in a wide range format.)}
#' For scoring integer and continuous forecasts a `sample` column is needed:
#' \itemize{
#'   \item `sample` - an index to identify the predictive samples in the
#'   prediction column generated by one model for one true value. Only
#'   necessary for continuous and integer forecasts, not for
#'   binary predictions.}
#' For scoring predictions in a quantile-format forecast you should provide
#' a column called `quantile`:
#'   - `quantile`: quantile to which the prediction corresponds
#'
#' In addition a `model` column is suggested and if not present this will be
#' flagged and added to the input data with all forecasts assigned as an
#' "unspecified model").
#'
#' You can check the format of your data using [check_forecasts()] and there
#' are examples for each format ([example_quantile], [example_continuous],
#' [example_integer], and [example_binary]).
#'
#' @param metrics the metrics you want to have in the output. If `NULL` (the
#' default), all available metrics will be computed. For a list of available
#' metrics see [available_metrics()], or  check the [metrics] data set.
#'
#' @param ... additional parameters passed down to [score_quantile()] (internal
#' function used for scoring forecasts in a quantile-based format).
#'
#' @return A data.table with unsummarised scores. There will be one score per
#' quantile or sample, which is usually not desired, so you should almost
#' always run [summarise_scores()] on the unsummarised scores.
#'
#' @importFrom data.table ':=' as.data.table
#'
#' @examples
#' library(magrittr) # pipe operator
#' \dontshow{
#'   data.table::setDTthreads(2) # restricts number of cores used on CRAN
#' }
#'
#' check_forecasts(example_quantile)
#' score(example_quantile) %>%
#'   add_coverage(by = c("model", "target_type")) %>%
#'   summarise_scores(by = c("model", "target_type"))
#'
#' # set forecast unit manually (to avoid issues with scoringutils trying to
#' # determine the forecast unit automatically), check forecasts before scoring
#' example_quantile %>%
#'   set_forecast_unit(
#'     c("location", "target_end_date", "target_type", "horizon", "model")
#'   ) %>%
#'   check_forecasts() %>%
#'   score()
#'
#' # forecast formats with different metrics
#' \dontrun{
#' score(example_binary)
#' score(example_quantile)
#' score(example_integer)
#' score(example_continuous)
#' }
#'
#' # score point forecasts (marked by 'NA' in the quantile column)
#' score(example_point) %>%
#'   summarise_scores(by = "model", na.rm = TRUE)
#'
#' @author Nikos Bosse \email{nikosbosse@@gmail.com}
#' @references Funk S, Camacho A, Kucharski AJ, Lowe R, Eggo RM, Edmunds WJ
#' (2019) Assessing the performance of real-time epidemic forecasts: A
#' case study of Ebola in the Western Area region of Sierra Leone, 2014-15.
#' PLoS Comput Biol 15(2): e1006785. \doi{10.1371/journal.pcbi.1006785}
#' @export

score <- function(data,
                  metrics = NULL,
                  ...) {

  # preparations ---------------------------------------------------------------
  if (is_scoringutils_check(data)) {
    check_data <- data
  } else {
    check_data <- check_forecasts(data)
  }

  data <- check_data$cleaned_data
  prediction_type <- check_data$prediction_type
  forecast_unit <- check_data$forecast_unit
  target_type <- check_data$target_type

  # check metrics are available or set to all metrics --------------------------
  metrics <- check_metrics(metrics)

  # Score binary predictions ---------------------------------------------------
  if (target_type == "binary") {
    scores <- score_binary(
      data = data,
      forecast_unit = forecast_unit,
      metrics = metrics
    )
  }

  # Score quantile predictions -------------------------------------------------
  if (prediction_type == "quantile") {
    scores <- score_quantile(
      data = data,
      forecast_unit = forecast_unit,
      metrics = metrics,
      ...
    )
  }

  # Score integer or continuous predictions ------------------------------------
  if (prediction_type %in% c("integer", "continuous") && (target_type != "binary")) {
    scores <- score_sample(
      data = data,
      forecast_unit = forecast_unit,
      metrics = metrics,
      prediction_type = prediction_type
    )
  }

  return(scores[])
}
