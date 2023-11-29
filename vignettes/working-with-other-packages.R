## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE,
                      fig.width = 7,
                      collapse = TRUE,
                      comment = "#>")
library(scoringutils)
library(magrittr)
library(dplyr)
library(data.table)
library(ggplot2)
library(knitr)

## -----------------------------------------------------------------------------
library(yardstick)

class_metrics <- metric_set(accuracy, kap)

example_binary |>
  to_yardstick_binary_class() |>
  group_by(model) |>
  class_metrics(truth = true_value, estimate = prediction)


## -----------------------------------------------------------------------------
example_binary |>
  to_yardstick_binary_class_prob() |>
  group_by(model) |>
  filter(!is.na(prediction)) |>
  average_precision(truth = true_value, prediction, event_level = "first")

## -----------------------------------------------------------------------------
example_continuous |>
  group_by(model) |>
  mae(truth = true_value, estimate = prediction)

## ---- eval =FALSE-------------------------------------------------------------
#  s <- score(example_binary)
#  s <- s[model %in% c("EuroCOVIDhub-baseline", "EuroCOVIDhub-ensemble")]
#  library(probably)
#  cal_plot_breaks(.data = s, truth = true_value, estimate = prediction, .by = model)
#  cal_plot_windowed(.data = s, truth = true_value, estimate = prediction, .by = model)
#  cal_plot_logistic(.data = s, truth = true_value, estimate = prediction, .by = model)

## -----------------------------------------------------------------------------
library(predtools)
s <- score(example_binary)
s <- s[model %in% c("EuroCOVIDhub-baseline", "EuroCOVIDhub-ensemble")]

calibration_plot(data = s, obs = "true_value",
                 pred = "prediction", group = "model")

## -----------------------------------------------------------------------------
library(scoring)
calcscore(
  true_value ~ prediction,
  data = example_binary,
  fam = "pow",
  param = 2,
  bounds = c(-1,1)
)

## -----------------------------------------------------------------------------
library(verification)

# discrimination plot for binary data
# shows how often models made forecasts with different levels of confidence --> can visually assess the forecasts
df <- example_binary[!is.na(prediction)]
discrimination.plot(df$model, df$prediction)

# receiver operating characteristic curve for binary predicitons
roc.plot(x = df$true_value, pred = df$prediction)


# scoring binary forecasts with verification - binary/probabilistic case
df <- example_binary[(model == "EuroCOVIDhub-ensemble" & horizon == 2 & target_type == "Cases")]
res <- verify(obs = df$true_value, pred = df$prediction)
summary(res)

# attribute plot and reliability plot
attribute(res)
reliability.plot(res)

# scoring continuous point forecasts
df <- example_continuous[(model == "EuroCOVIDhub-ensemble" & horizon == 2 & target_type == "Cases")][,
                         .('obs' = mean(true_value),
                           'pred' = mean(prediction)
                         ),
                         by = c("location", "target_end_date")
]

res <- verify(obs = df$obs, pred = df$pred, obs.type = "cont", frcst.type = "cont")
summary(res)
# plot(res)

# scoring quantile forecasts
df <- example_quantile[(model == "EuroCOVIDhub-ensemble" & horizon == 2 & target_type == "Cases")]

res_scoringutils <- score(df) |>
  summarise_scores(by = "model")

qs <- quantile_score(true_values = df$true_value, predictions = df$prediction,
               quantiles = df$quantile)

all.equal(mean(qs), res_scoringutils$interval_score)

## -----------------------------------------------------------------------------
library(yardstick)
