## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  fig.width = 7,
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(scoringutils)
library(data.table)

## -----------------------------------------------------------------------------
data <- scoringutils::quantile_example_data_plain
print(data, 3, 3)
scoringutils::eval_forecasts(data, 
                             summarise_by = c("model", "quantile", "range"))

## -----------------------------------------------------------------------------
scoringutils::plot_predictions(data, x = "id", range = c(0, 90), 
                               facet_formula = ~ model)

## -----------------------------------------------------------------------------
scores <- scoringutils::eval_forecasts(data, 
                             summarise_by = c("model"))
scoringutils::score_table(scores)

## ----out.width="50%", fig.show="hold"-----------------------------------------
scores <- scoringutils::eval_forecasts(data, 
                             summarise_by = c("model", "range", "quantile"))
scoringutils::interval_coverage(scores) + 
  ggplot2::ggtitle("Interval Coverage")

scoringutils::quantile_coverage(scores) + 
  ggplot2::ggtitle("Quantile Coverage")

## -----------------------------------------------------------------------------
scores <- scoringutils::eval_forecasts(data, 
                             summarise_by = c("model"))
scoringutils::wis_components(scores)

## -----------------------------------------------------------------------------
scores <- scoringutils::eval_forecasts(data, 
                             summarise_by = c("model", "range"))
scoringutils::range_plot(scores, y = "interval_score")

## -----------------------------------------------------------------------------
scores <- scoringutils::eval_forecasts(data, 
                             summarise_by = c("model", "horizon"))
scores[, horizon := as.factor(horizon)]
scoringutils::score_heatmap(scores, 
                            x = "horizon", metric = "bias")

## -----------------------------------------------------------------------------
print(scoringutils::quantile_example_data_plain, 3, 3)
print(scoringutils::quantile_example_data_long, 3, 3)

## -----------------------------------------------------------------------------
print(scoringutils::integer_example_data, 3, 3)
print(scoringutils::continuous_example_data, 3, 3)

## -----------------------------------------------------------------------------
print(scoringutils::binary_example_data, 3, 3)

## ----eval=FALSE---------------------------------------------------------------
#  scoringutils::sample_to_quantile() # convert from sample based to quantile format
#  scoringutils::range_to_quantile() # convert from range format to plain quantile
#  scoringutils::quantile_to_range() # convert the other way round
#  scoringutils::quantile_to_long() # convert range based format from wide to long
#  scoringutils::quantile_to_wide() # convert the other way round

## -----------------------------------------------------------------------------
## integer valued forecasts
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
bias(true_values, predictions)

## continuous forecasts
true_values <- rnorm(30, mean = 1:30)
predictions <- replicate(200, rnorm(30, mean = 1:30))
bias(true_values, predictions)

## -----------------------------------------------------------------------------
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
sharpness(predictions)

## -----------------------------------------------------------------------------
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
crps(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
dss(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- rnorm(30, mean = 1:30)
predictions <- replicate(200, rnorm(n = 30, mean = 1:30))
logs(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- sample(c(0,1), size = 30, replace = TRUE)
predictions <- runif(n = 30, min = 0, max = 1)

brier_score(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- rnorm(30, mean = 1:30)
interval_range <- 90
alpha <- (100 - interval_range) / 100
lower <- qnorm(alpha/2, rnorm(30, mean = 1:30))
upper <- qnorm((1- alpha/2), rnorm(30, mean = 1:30))

interval_score(true_values = true_values,
               lower = lower,
               upper = upper,
               interval_range = interval_range)

