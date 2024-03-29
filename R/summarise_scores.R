#' @title Summarise scores as produced by [score()]
#'
#' @description Summarise scores as produced by [score()]
#'
#' @inheritParams pairwise_comparison
#' @inheritParams score
#' @param by character vector with column names to summarise scores by. Default
#' is `NULL`, meaning that the only summary that takes is place is summarising
#' over samples or quantiles (in case of quantile-based forecasts), such that
#' there is one score per forecast as defined by the *unit of a single forecast*
#' (rather than one score for every sample or quantile).
#' The *unit of a single forecast* is determined by the columns present in the
#' input data that do not correspond to a metric produced by [score()], which
#' indicate indicate a grouping of forecasts (for example there may be one
#' forecast per day, location and model). Adding additional, unrelated, columns
#' may alter results in an unpredictable way.
#' @param across character vector with column names from the vector of variables
#' that define the *unit of a single forecast* (see above) to summarise scores
#' across (meaning that the specified columns will be dropped). This is an
#' alternative to specifying `by` directly. If `NULL` (default), then `by` will
#' be used or inferred internally if also not specified. Only  one of `across`
#' and `by`  may be used at a time.
#' @param fun a function used for summarising scores. Default is `mean`.
#' @param relative_skill logical, whether or not to compute relative
#' performance between models based on pairwise comparisons.
#' If `TRUE` (default is `FALSE`), then a column called
#' 'model' must be present in the input data. For more information on
#' the computation of relative skill, see [pairwise_comparison()].
#' Relative skill will be calculated for the aggregation level specified in
#' `by`.
#' @param relative_skill_metric character with the name of the metric for which
#' a relative skill shall be computed. If equal to 'auto' (the default), then
#' this will be either interval score, CRPS or Brier score (depending on which
#' of these is available in the input data)
#' @param metric  `r lifecycle::badge("deprecated")` Deprecated in 1.1.0. Use
#' `relative_skill_metric` instead.
#' @param baseline character string with the name of a model. If a baseline is
#' given, then a scaled relative skill with respect to the baseline will be
#' returned. By default (`NULL`), relative skill will not be scaled with
#' respect to a baseline model.
#' @param ... additional parameters that can be passed to the summary function
#' provided to `fun`. For more information see the documentation of the
#' respective function.
#' @examples
#' \dontshow{
#'   data.table::setDTthreads(2) # restricts number of cores used on CRAN
#' }
#' library(magrittr) # pipe operator
#'
#' scores <- score(example_continuous)
#' summarise_scores(scores)
#'
#'
#' # summarise over samples or quantiles to get one score per forecast
#' scores <- score(example_quantile)
#' summarise_scores(scores)
#'
#' # get scores by model
#' summarise_scores(scores,by = "model")
#'
#' # get scores by model and target type
#' summarise_scores(scores, by = c("model", "target_type"))
#'
#' # Get scores summarised across horizon, forecast date, and target end date
#' summarise_scores(
#'  scores, across = c("horizon", "forecast_date", "target_end_date")
#' )
#'
#' # get standard deviation
#' summarise_scores(scores, by = "model", fun = sd)
#'
#' # round digits
#' summarise_scores(scores,by = "model") %>%
#'   summarise_scores(fun = signif, digits = 2)
#'
#' # get quantiles of scores
#' # make sure to aggregate over ranges first
#' summarise_scores(scores,
#'   by = "model", fun = quantile,
#'   probs = c(0.25, 0.5, 0.75)
#' )
#'
#' # get ranges
#' # summarise_scores(scores, by = "range")
#' @export
#' @keywords scoring

summarise_scores <- function(scores,
                             by = NULL,
                             across = NULL,
                             fun = mean,
                             relative_skill = FALSE,
                             relative_skill_metric = "auto",
                             metric = deprecated(),
                             baseline = NULL,
                             ...) {
  if (lifecycle::is_present(metric)) {
    lifecycle::deprecate_warn(
      "1.1.0", "summarise_scores(metric)",
      "summarise_scores(relative_skill_metric)"
    )
  }

  if (!is.null(across) && !is.null(by)) {
    stop("You cannot specify both 'across' and 'by'. Please choose one.")
  }

  # preparations ---------------------------------------------------------------
  # get unit of a single forecast
  forecast_unit <- get_forecast_unit(scores)

  # if by is not provided, set to the unit of a single forecast
  if (is.null(by)) {
    by <- forecast_unit
  }

  # if across is provided, remove from by
  if (!is.null(across)) {
    if (!all(across %in% by)) {
      stop(
        "The columns specified in 'across' must be a subset of the columns ",
        "that define the forecast unit (possible options are ",
        toString(by),
        "). Please check your input and try again."
      )
    }
    by <- setdiff(by, across)
  }

  # check input arguments and check whether relative skill can be computed
  relative_skill <- check_summary_params(
    scores = scores,
    by = by,
    relative_skill = relative_skill,
    baseline = baseline,
    metric = relative_skill_metric
  )

  # get all available metrics to determine names of columns to summarise over
  cols_to_summarise <- paste0(available_metrics(), collapse = "|")

  # takes the mean over ranges and quantiles first, if neither range nor
  # quantile are in `by`. Reason to do this is that summaries may be
  # inaccurate if we treat individual quantiles as independent forecasts
  scores <- scores[, lapply(.SD, base::mean, ...),
    by = c(unique(c(forecast_unit, by))),
    .SDcols = colnames(scores) %like% cols_to_summarise
  ]

  # do pairwise comparisons ----------------------------------------------------
  if (relative_skill) {
    pairwise <- pairwise_comparison(
      scores = scores,
      metric = relative_skill_metric,
      baseline = baseline,
      by = by
    )

    if (!is.null(pairwise)) {
      # delete unnecessary columns
      pairwise[, c(
        "compare_against", "mean_scores_ratio",
        "pval", "adj_pval"
      ) := NULL]
      pairwise <- unique(pairwise)

      # merge back
      scores <- merge(
        scores, pairwise, all.x = TRUE, by = get_forecast_unit(pairwise)
      )
    }
  }

  # summarise scores -----------------------------------------------------------
  scores <- scores[, lapply(.SD, fun, ...),
    by = c(by),
    .SDcols = colnames(scores) %like% cols_to_summarise
  ]

  # remove unnecessary columns -------------------------------------------------
  # if neither quantile nor range are in by, remove coverage and
  # quantile_coverage because averaging does not make sense
  if (!("range" %in% by) && ("coverage" %in% colnames(scores))) {
    scores[, "coverage" := NULL]
  }
  if (!("quantile" %in% by) && "quantile_coverage" %in% names(scores)) {
    scores[, "quantile_coverage" := NULL]
  }

  return(scores[])
}

#' @rdname summarise_scores
#' @keywords scoring
#' @export
summarize_scores <- summarise_scores


#' @title Check input parameters for [summarise_scores()]
#'
#' @description A helper function to check the input parameters for
#' [score()].
#'
#' @inheritParams summarise_scores
#'
#' @keywords internal
check_summary_params <- function(scores,
                                 by,
                                 relative_skill,
                                 baseline,
                                 metric) {

  # check that columns in 'by' are actually present ----------------------------
  if (!all(by %in% c(colnames(scores), "range", "quantile"))) {
    not_present <- setdiff(by, c(colnames(scores), "range", "quantile"))
    msg <- paste0(
      "The following items in `by` are not",
      "valid column names of the data: '",
      toString(not_present),
      "'. Check and run `summarise_scores()` again"
    )
    stop(msg)
  }

  # error handling for relative skill computation ------------------------------
  if (relative_skill) {
    if (!("model" %in% colnames(scores))) {
      warning(
        "to compute relative skills, there must column present ",
        "called model'. Relative skill will not be computed"
      )
      relative_skill <- FALSE
    }
    models <- unique(scores$model)
    if (length(models) < 2 + (!is.null(baseline))) {
      warning(
        "you need more than one model non-baseline model to make model ",
        "comparisons. Relative skill will not be computed"
      )
      relative_skill <- FALSE
    }
    if (!is.null(baseline) && !(baseline %in% models)) {
      warning(
        "The baseline you provided for the relative skill is not one of ",
        "the models in the data. Relative skill will not be computed"
      )
      relative_skill <- FALSE
    }
    if (metric != "auto" && !(metric %in% available_metrics())) {
      warning(
        "argument 'metric' must either be 'auto' or one of the metrics that ",
        "can be computed. Relative skill will not be computed"
      )
      relative_skill <- FALSE
    }
  }
  return(relative_skill)
}



#' @title Add coverage of central prediction intervals
#'
#' @description Adds a column with the coverage of central prediction intervals
#' to unsummarised scores as produced by [score()]
#'
#' @details
#' The coverage values that are added are computed according to the values
#' specified in `by`. If, for example, `by = "model"`, then there will be one
#' coverage value for every model and [add_coverage()] will compute the coverage
#' for every model across the values present in all other columns which define
#' the unit of a single forecast.
#'
#' @inheritParams summarise_scores
#' @param by character vector with column names to add the coverage for.
#' @param ranges numeric vector of the ranges of the central prediction intervals
#' for which coverage values shall be added.
#' @return a data.table with unsummarised scores with columns added for the
#' coverage of the central prediction intervals. While the overall data.table
#' is still unsummarised, note that for the coverage columns some level of
#' summary is present according to the value specified in `by`.
#' @examples
#' library(magrittr) # pipe operator
#' \dontshow{
#'   data.table::setDTthreads(2) # restricts number of cores used on CRAN
#' }
#' score(example_quantile) %>%
#'   add_coverage(by = c("model", "target_type")) %>%
#'   summarise_scores(by = c("model", "target_type")) %>%
#'   summarise_scores(fun = signif, digits = 2)
#' @export
#' @keywords scoring

add_coverage <- function(scores,
                         by,
                         ranges = c(50, 90)) {
  summarised_scores <- summarise_scores(
    scores,
    by = c(by, "range")
  )[range %in% ranges]


  # create cast formula
  cast_formula <-
    paste(
      paste(by, collapse = "+"),
      "~",
      "paste0('coverage_', range)"
    )

  coverages <- dcast(
    summarised_scores,
    value.var = "coverage",
    formula = cast_formula
  )

  scores_with_coverage <- merge(scores, coverages, by = by)
  return(scores_with_coverage[])
}
