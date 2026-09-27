## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>"
)
data.table::setDTthreads(2)

## ----counts-------------------------------------------------------------------
library(scoringutils)
fc <- as_forecast_quantile(example_quantile)
get_forecast_counts(fc, by = c("model", "target_type"))

## ----missing-detail-----------------------------------------------------------
death_counts <- get_forecast_counts(
  fc,
  by = c("model", "target_type", "location", "target_end_date")
)
death_counts[
  model == "epiforecasts-EpiNow2" &
    target_type == "Deaths" &
    count == 0
]

## ----score--------------------------------------------------------------------
scores <- score(fc)

## ----naive-summary------------------------------------------------------------
summarise_scores(scores, by = "model")

## ----filter-default-----------------------------------------------------------
scores_filtered <- filter_scores(scores)
summarise_scores(scores_filtered, by = "model")

## ----filter-relaxed-----------------------------------------------------------
scores_relaxed <- filter_scores(
  scores,
  strategy = filter_to_intersection(min_coverage = 0.75)
)
summarise_scores(scores_relaxed, by = "model")

## ----filter-include-----------------------------------------------------------
scores_epinow2 <- filter_scores(
  scores,
  strategy = filter_to_include("epiforecasts-EpiNow2")
)
summarise_scores(scores_epinow2, by = "model")

## ----impute-na----------------------------------------------------------------
scores_na <- impute_missing_scores(
  scores,
  strategy = impute_na_score()
)
summarise_scores(scores_na, by = "model")

## ----impute-worst-------------------------------------------------------------
scores_worst <- impute_missing_scores(
  scores,
  strategy = impute_worst_score()
)
summarise_scores(scores_worst, by = "model")

## ----imputed-check------------------------------------------------------------
scores_worst[
  (.imputed),
  .(n_imputed = .N),
  by = c("model", "target_type")
]

## ----impute-model-------------------------------------------------------------
scores_ref <- impute_missing_scores(
  scores,
  strategy = impute_model_score("EuroCOVIDhub-baseline")
)
summarise_scores(scores_ref, by = "model")

## ----impute-mean--------------------------------------------------------------
scores_mean <- impute_missing_scores(
  scores,
  strategy = impute_mean_score()
)
summarise_scores(scores_mean, by = "model")

## ----pipeline-----------------------------------------------------------------
result <- scores |>
  filter_scores(
    strategy = filter_to_include("epiforecasts-EpiNow2")
  ) |>
  impute_missing_scores(
    strategy = impute_worst_score()
  )
summarise_scores(result, by = "model")

