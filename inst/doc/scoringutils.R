## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(scoringutils)
library(data.table)

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

## -----------------------------------------------------------------------------
library(data.table)

# load example data
binary_example <- data.table::setDT(scoringutils::binary_example_data)
print(binary_example, 3, 3)

## -----------------------------------------------------------------------------
# score forecasts
eval <- scoringutils::eval_forecasts(binary_example)
print(eval)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(binary_example, summarised = FALSE)
print(eval, 3, 3)

## -----------------------------------------------------------------------------
quantile_example <- data.table::setDT(scoringutils::quantile_example_data)
print(quantile_example, 3, 3)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(quantile_example)
print(eval)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(quantile_example, summarised = FALSE)
print(eval, 3, 3)

## -----------------------------------------------------------------------------
integer_example <- data.table::setDT(scoringutils::integer_example_data)
print(integer_example, 3, 3)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(integer_example)
print(eval)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(integer_example, summarised = FALSE)
print(eval, 3, 3)

## -----------------------------------------------------------------------------
continuous_example <- data.table::setDT(scoringutils::continuous_example_data)
print(continuous_example, 3, 3)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(continuous_example)
print(eval)

## -----------------------------------------------------------------------------
eval <- scoringutils::eval_forecasts(continuous_example, summarised = FALSE)
print(eval, 3, 3)


