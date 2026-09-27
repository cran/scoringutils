## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(scoringutils)

example_univ_single <- example_sample_continuous[
  target_type == "Cases" &
    location == "DE" &
    forecast_date == "2021-05-03" &
    target_end_date == "2021-05-15" &
    horizon == 2 &
    model == "EuroCOVIDhub-ensemble"
]
example_univ_single

## -----------------------------------------------------------------------------
score(example_univ_single)

## -----------------------------------------------------------------------------
example_univ_multi <- example_sample_continuous[
  target_type == "Cases" &
    forecast_date == "2021-05-03" &
    target_end_date == "2021-05-15" &
    horizon == 2 &
    model == "EuroCOVIDhub-ensemble"
]
example_univ_multi

## -----------------------------------------------------------------------------
score(example_univ_multi)

## -----------------------------------------------------------------------------
example_multiv <- as_forecast_multivariate_sample(
  data = example_univ_multi,
  c("location", "location_name")
)
example_multiv

## -----------------------------------------------------------------------------
score(example_multiv)

## -----------------------------------------------------------------------------
score(
  example_multiv,
  metrics = list(
    energy_score = energy_score_multivariate,
    variogram_score = purrr::partial( # nolint: namespace_linter.
      variogram_score_multivariate, p = 1
    )
  )
)

## -----------------------------------------------------------------------------
example_cases <- na.omit(
  example_sample_continuous[
    target_type == "Cases" &
      model == "EuroCOVIDhub-ensemble"
  ]
)

example_traj <- as_forecast_multivariate_sample(
  data = example_cases,
  joint_across = c("horizon", "target_end_date")
)

head(score(example_traj), 3)

## -----------------------------------------------------------------------------
example_point_multi <- example_point[
  target_type == "Cases" &
    forecast_date == "2021-05-03" &
    target_end_date == "2021-05-15" &
    horizon == 2 &
    model == "EuroCOVIDhub-ensemble"
]

example_mv_point <- as_forecast_multivariate_point(
  data = na.omit(example_point_multi),
  joint_across = c("location", "location_name")
)
score(example_mv_point)

## -----------------------------------------------------------------------------
library(ggplot2)
library(data.table)

cases_de <- as.data.table(example_sample_continuous)[
  target_type == "Cases" &
    location == "DE" &
    forecast_date == "2021-05-03" &
    model %in% c("EuroCOVIDhub-ensemble", "epiforecasts-EpiNow2")
]

band <- cases_de[, .(
  median = median(predicted),
  lower = quantile(predicted, 0.25),
  upper = quantile(predicted, 0.75)
), by = .(model, target_end_date)]

observed <- unique(cases_de[, .(target_end_date, observed)])

ggplot(band, aes(target_end_date, median, colour = model, fill = model)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, colour = NA) +
  geom_line() +
  geom_line(
    data = observed, aes(target_end_date, observed),
    inherit.aes = FALSE, linetype = "dashed"
  ) +
  geom_point(
    data = observed, aes(target_end_date, observed),
    inherit.aes = FALSE
  ) +
  labs(x = "Target date", y = "Weekly cases", colour = "Model", fill = "Model") +
  theme_scoringutils() +
  theme(legend.position = "bottom")

## -----------------------------------------------------------------------------
cases_mv <- as_forecast_multivariate_sample(
  data = na.omit(cases_de),
  joint_across = c("horizon", "target_end_date")
)
score(cases_mv)[, c("model", "energy_score", "variogram_score")]

