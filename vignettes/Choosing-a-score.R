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

## ----score-convergence, echo = FALSE, fig.cap="Top: Estimation of scores from predictive samples (adapted from \\citep{jordanEvaluatingProbabilisticForecasts2019}). Scores were computed based on samples of differing size (from 10 to 100,000). This was repeated 500 times for each sample size. The black line is the mean score across the 500 repetitions, shaded areas represent 50\\% and 90\\% intervals, and the dashed line represents the true calculated score.  Bottom left: Change in score when the uncertainty of the predictive distribution is changed. The true distribution is N(0,5) with the true standard deviation marked with a dashed line, while the standard deviation of the predictive distribution is varied along the x-axis. Log score and DSS clearly punish overconfidence much more severely than underconfidence. Bottom right: Score achieved for a standard normal predictive distribution (illustrated in grey) and different true observed values. Log score and DSS punish instances more harshly where the observed value is far away from the predictive distribution.", fig.show="hold"----
include_graphics("score-convergence-outliers.png")

## ----score-locality, echo = FALSE, fig.cap="Probabilities assigned by two hypothetical forecasters, A and B, to the possible number of goals in a football match. The true number later observed, 2, is marked with a dashed line. Both forecasters assign a probability of 0.35 to the observed outcome, 2. Forecaster A's prediction is centred around the observed value, while Forecaster B assigns significant probability to outcomes far away from the observed value. Judged by a local score like the Log Score, both forecasters receive the same score. A global score like the CRPS and the DSS penalises forecaster B more severely."----

include_graphics("score-locality.png")

## ----score-scale, echo = FALSE, fig.cap="Scores depend on the variability of the data and therefore implicitly on the order of magnitude of the observed value. A: Mean and standard deviation of scores from a simulation of perfect forecasts with predictive distribution $F$ equal to the true data-generating distribution $G$. The standard deviation of the two distributions was held constant at $\\sigma$, and for different mean values $\\mu$ 100 pairs of forecasts and observations were simulated. Every simulated forecast consisted of 1000 draws from the data-generating distribution $G$ and 5000 draws from the (same) predictive distribution $F$. For all three scoring rules, mean and sd of the calculated scores stay constant regardless of the mean $\\mu$ of $F$ and $G$. B: Same setup, but now the mean of $F$ and $G$ was held constant at $\\mu = 1$ and the standard deviation $\\sigma$ was varied. Average scores increase for all three scoring rules, but most strongly for the CRPS. Standard deviations of the estimated scores stay roughly constant for the DSS and log score, but also increase for the CRPS. C: Scores for forecasts of COVID-19 cases and deaths from the European Forecast Hub ensemble based on the example data provided in the package."----

include_graphics("illustration-effect-scale.png")

