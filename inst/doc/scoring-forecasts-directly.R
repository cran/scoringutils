## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  fig.width = 7,
  collapse = TRUE,
  comment = "#>"
)
library(scoringutils)
library(magrittr)
library(data.table)
library(ggplot2)

## -----------------------------------------------------------------------------
## integer valued forecasts
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
bias_sample(true_values, predictions)

## continuous forecasts
true_values <- rnorm(30, mean = 1:30)
predictions <- replicate(200, rnorm(30, mean = 1:30))
bias_sample(true_values, predictions)

## -----------------------------------------------------------------------------
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
mad_sample(predictions)

## -----------------------------------------------------------------------------
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
crps_sample(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- rpois(30, lambda = 1:30)
predictions <- replicate(200, rpois(n = 30, lambda = 1:30))
dss_sample(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- rnorm(30, mean = 1:30)
predictions <- replicate(200, rnorm(n = 30, mean = 1:30))
logs_sample(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- sample(c(0, 1), size = 30, replace = TRUE)
predictions <- runif(n = 30, min = 0, max = 1)

brier_score(true_values, predictions)

## -----------------------------------------------------------------------------
true_values <- rnorm(30, mean = 1:30)
interval_range <- 90
alpha <- (100 - interval_range) / 100
lower <- qnorm(alpha / 2, rnorm(30, mean = 1:30))
upper <- qnorm((1 - alpha / 2), rnorm(30, mean = 1:30))

interval_score(
  true_values = true_values,
  lower = lower,
  upper = upper,
  interval_range = interval_range
)

