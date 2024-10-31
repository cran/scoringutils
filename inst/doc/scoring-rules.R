## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  fig.width = 7,
  collapse = TRUE,
  comment = "#>",
  cache = FALSE
)
library(scoringutils)
library(data.table)

## ----echo=FALSE, out.width="100%", fig.cap="Input and output formats: metrics for point."----
knitr::include_graphics(file.path("scoring-rules", "input-point.png"))

## -----------------------------------------------------------------------------
set.seed(123)
n <- 1000
observed <- rnorm(n, 5, 4)^2

predicted_mu <- mean(observed)
predicted_not_mu <- predicted_mu - rnorm(n, 10, 2)

mean(Metrics::ae(observed, predicted_mu))
mean(Metrics::ae(observed, predicted_not_mu))

mean(Metrics::se(observed, predicted_mu))
mean(Metrics::se(observed, predicted_not_mu))

## ----echo=FALSE, out.width="100%", fig.cap="Input and output formats: metrics for binary forecasts."----
knitr::include_graphics(file.path("scoring-rules", "input-binary.png"))

## -----------------------------------------------------------------------------
n <- 1e6
p_true <- 0.7
observed <- factor(rbinom(n = n, size = 1, prob = p_true), levels = c(0, 1))

p_over <- p_true + 0.15
p_under <- p_true - 0.15

abs(mean(brier_score(observed, p_true)) - mean(brier_score(observed, p_over)))
abs(mean(brier_score(observed, p_true)) - mean(brier_score(observed, p_under)))

## -----------------------------------------------------------------------------
abs(mean(logs_binary(observed, p_true)) - mean(logs_binary(observed, p_over)))
abs(mean(logs_binary(observed, p_true)) - mean(logs_binary(observed, p_under)))

## ----echo=FALSE, out.width="100%", fig.cap="Input and output formats: metrics for sample-based forecasts."----
knitr::include_graphics(file.path("scoring-rules", "input-sample.png"))

## ----echo=FALSE, out.width="100%", fig.cap="Input and output formats: metrics for quantile-based forecasts."----
knitr::include_graphics(file.path("scoring-rules", "input-quantile.png"))

