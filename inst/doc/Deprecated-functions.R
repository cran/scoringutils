## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
#' @title Merge forecast data and observations
#'
#' @description
#'
#' The function more or less provides a wrapper around `merge` that
#' aims to handle the merging well if additional columns are present
#' in one or both data sets. If in doubt, you should probably merge the
#' data sets manually.
#'
#' @param forecasts A data.frame with the forecast data (as can be passed to
#'   [score()]).
#' @param observations A data.frame with the observations.
#' @param join Character, one of `c("left", "full", "right")`. Determines the
#'   type of the join. Usually, a left join is appropriate, but sometimes you
#'   may want to do a full join to keep dates for which there is a forecast, but
#'   no ground truth data.
#' @param by Character vector that denotes the columns by which to merge. Any
#'   value that is not a column in observations will be removed.
#' @returns a data.table with forecasts and observations
#' @importFrom checkmate assert_subset
#' @importFrom data.table as.data.table
#' @keywords data-handling
#' @export

merge_pred_and_obs <- function(forecasts, observations,
                               join = c("left", "full", "right"),
                               by = NULL) {
  forecasts <- as.data.table(forecasts)
  observations <- as.data.table(observations)
  join <- match.arg(join)
  assert_subset(by, intersect(names(forecasts), names(observations)))

  if (is.null(by)) {
    protected_columns <- c(
      "predicted", "observed", "sample_id", "quantile_level",
      "interval_range", "boundary"
    )
    by <- setdiff(colnames(forecasts), protected_columns)
  }

  obs_cols <- colnames(observations)
  by <- intersect(by, obs_cols)

  join <- match.arg(join)

  if (join == "left") {
    # do a left_join, where all data in the observations are kept.
    combined <- merge(observations, forecasts, by = by, all.x = TRUE)
  } else if (join == "full") {
    # do a full, where all data is kept.
    combined <- merge(observations, forecasts, by = by, all = TRUE)
  } else {
    combined <- merge(observations, forecasts, by = by, all.y = TRUE)
  }


  # get colnames that are the same for x and y
  colnames <- colnames(combined)
  colnames_x <- colnames[endsWith(colnames, ".x")]
  colnames_y <- colnames[endsWith(colnames, ".y")]

  # extract basenames
  basenames_x <- sub(".x$", "", colnames_x)
  basenames_y <- sub(".y$", "", colnames_y)

  # see whether the column name as well as the content is the same
  content_x <- as.list(combined[, ..colnames_x])
  content_y <- as.list(combined[, ..colnames_y])
  overlapping <- (content_x %in% content_y) & (basenames_x == basenames_y)
  overlap_names <- colnames_x[overlapping]
  basenames_overlap <- sub(".x$", "", overlap_names)

  # delete overlapping columns
  if (length(basenames_overlap) > 0) {
    combined[, paste0(basenames_overlap, ".x") := NULL]
    combined[, paste0(basenames_overlap, ".y") := NULL]
  }

  return(combined[])
}

