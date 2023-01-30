## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE,
                      fig.width = 7,
                      collapse = TRUE,
                      comment = "#>")
library(scoringutils)
library(magrittr)
library(data.table)
library(ggplot2)
library(knitr)

## ---- echo=FALSE--------------------------------------------------------------
requirements <- data.table(
  "Format" = c(
    "quantile-based", "sample-based", "binary", "pairwise-comparisons"
  ),
  `Required columns` = c(
    "'true_value', 'prediction', 'quantile'",
    "'true_value', 'prediction', 'sample'", "'true_value', 'prediction'",
    "additionally a column 'model'"
  )
)
kable(requirements)

## -----------------------------------------------------------------------------
head(example_quantile)

## -----------------------------------------------------------------------------
check_forecasts(example_quantile)

## -----------------------------------------------------------------------------
avail_forecasts(example_quantile, by = c("model", "target_type"))

## ---- fig.width=11, fig.height=6----------------------------------------------
example_quantile %>%
  avail_forecasts(by = c("model", "forecast_date", "target_type")) %>%
  plot_avail_forecasts() +
  facet_wrap(~ target_type)

## ---- fig.width = 9, fig.height = 6-------------------------------------------
example_quantile %>%
  make_NA(what = "truth", 
          target_end_date >= "2021-07-15", 
          target_end_date < "2021-05-22"
  ) %>%
  make_NA(what = "forecast",
          model != 'EuroCOVIDhub-ensemble', 
          forecast_date != "2021-06-28"
  ) %>%
  plot_predictions(
    x = "target_end_date",
    by = c("target_type", "location")
  ) +
  facet_wrap(target_type ~ location, ncol = 4, scales = "free") 

## -----------------------------------------------------------------------------
score(example_quantile) %>%
  head()

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores(by = c("model", "target_type")) %>%
  summarise_scores(fun = signif, digits = 2) %>%
  kable()

## -----------------------------------------------------------------------------
score(example_quantile) %>%
  summarise_scores()

## -----------------------------------------------------------------------------
score(example_point) %>% 
  summarise_scores(by = "model", na.rm = TRUE)

## -----------------------------------------------------------------------------
score(example_quantile) %>%
  add_coverage(ranges = c(50, 90), by = c("model", "target_type")) %>%
  summarise_scores(by = c("model", "target_type")) %>%
  summarise_scores(fun = signif, digits = 2)

## -----------------------------------------------------------------------------
score(example_quantile) %>%
  summarise_scores(by = c("model", "target_type"), 
                   relative_skill = TRUE, 
                   baseline = "EuroCOVIDhub-ensemble")

## -----------------------------------------------------------------------------
score(example_integer) %>%
  summarise_scores(by = c("model", "target_type"), na.rm = TRUE) %>%
  summarise_scores(fun = signif, digits = 2) %>%
  plot_score_table(by = "target_type") + 
  facet_wrap(~ target_type, nrow = 1)

## ---- fig.width=11, fig.height=6----------------------------------------------
score(example_continuous) %>%
  summarise_scores(by = c("model", "location", "target_type")) %>%
  plot_heatmap(x = "location", metric = "bias") + 
    facet_wrap(~ target_type)

## -----------------------------------------------------------------------------
score(example_quantile) %>%
  summarise_scores(by = c("target_type", "model")) %>%
  plot_wis() + 
  facet_wrap(~ target_type, scales = "free")

## -----------------------------------------------------------------------------
example_continuous %>%
  pit(by = "model") 

## -----------------------------------------------------------------------------
example_continuous %>%
  pit(by = c("model", "target_type")) %>%
  plot_pit() + 
  facet_grid(model ~ target_type)

## -----------------------------------------------------------------------------
example_quantile[quantile %in% seq(0.1, 0.9, 0.1), ] %>%
  pit(by = c("model", "target_type")) %>%
  plot_pit() +
  facet_grid(model ~ target_type)

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores(by = c("model", "range")) %>%
  plot_interval_coverage()

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores(by = c("model", "quantile")) %>%
  plot_quantile_coverage()

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  pairwise_comparison(by = "model", baseline = "EuroCOVIDhub-baseline")

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores(
    by = "model", relative_skill = TRUE, baseline = "EuroCOVIDhub-baseline"
  )

## ---- fig.width=9, fig.height=7-----------------------------------------------
example_quantile %>%
  score() %>%
  pairwise_comparison(by = c("model", "target_type")) %>%
  plot_pairwise_comparison() +
  facet_wrap(~ target_type)

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores() %>%
  correlation()

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores() %>%
  correlation() %>%
  plot_correlation()

## -----------------------------------------------------------------------------
example_quantile %>%
  score() %>%
  summarise_scores(by = c("model", "range", "target_type")) %>%
  plot_ranges() +
  facet_wrap(~ target_type, scales = "free")

## -----------------------------------------------------------------------------
example_integer %>%
  sample_to_quantile(
    quantiles = c(0.01, 0.025, seq(0.05, 0.95, 0.05), 0.975, 0.99)
  ) %>%
  score() %>%
  add_coverage(by = c("model", "target_type"))

## -----------------------------------------------------------------------------
metrics

