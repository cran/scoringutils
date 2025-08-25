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
# parameters for multivariate normal example
set.seed(123)
d <- 10  # number of dimensions
m <- 50  # number of samples from multivariate forecast distribution

mu0 <- rep(0, d)
mu <- rep(1, d)

S0 <- S <- diag(d)
S0[S0 == 0] <- 0.2
S[S == 0] <- 0.1

# generate samples from multivariate normal distributions
obs <- drop(mu0 + rnorm(d) %*% chol(S0))
fc_sample <- replicate(m, drop(mu + rnorm(d) %*% chol(S)))

obs2 <- drop(mu0 + rnorm(d) %*% chol(S0))
fc_sample2 <- replicate(m, drop(mu + rnorm(d) %*% chol(S)))

## -----------------------------------------------------------------------------
scoringRules::es_sample(y = obs, dat = fc_sample)
# in the univariate case, Energy Score and CRPS are the same
# illustration: Evaluate forecast sample for the first variable
es_sr1 <- scoringRules::es_sample(y = obs, dat = fc_sample)
es_sr2 <- scoringRules::es_sample(y = obs2, dat = fc_sample2)
es_sr <- c(es_sr1, es_sr2)

es_su <- energy_score_multivariate(
  observed = c(obs, obs2),
  predicted = rbind(fc_sample, fc_sample2),
  mv_group_id = c(rep(1, d), rep(2, d))
)
all.equal(es_sr, es_su, tolerance = 1e-6, check.attributes = FALSE)

## -----------------------------------------------------------------------------
# illustration of observation weights for Energy Score
# example: equal weights for first half of draws; zero weights for other draws
w <- rep(c(1, 0), each = 0.5 * m) / (0.5 * m)

es_sr1 <- scoringRules::es_sample(y = obs, dat = fc_sample, w = w)
es_sr2 <- scoringRules::es_sample(y = obs2, dat = fc_sample2, w = w)
es_sr <- c(es_sr1, es_sr2)

es_su <- energy_score_multivariate(
  observed = c(obs, obs2),
  predicted = rbind(fc_sample, fc_sample2),
  mv_group_id = c(rep(1, d), rep(2, d)),
  w = w
)

all.equal(es_sr, es_su, tolerance = 1e-6, check.attributes = FALSE)

