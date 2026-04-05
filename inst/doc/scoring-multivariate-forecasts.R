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
    variogram_score = purrr::partial(
      variogram_score_multivariate, p = 1
    )
  )
)

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

