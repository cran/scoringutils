## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(scoringutils)
library(kableExtra)
library(magrittr)
library(knitr)
library(data.table)

## ----echo = FALSE, results = "asis"-------------------------------------------
data <- copy(metrics) 
setnames(data, old = c("Discrete", "Continuous", "Binary", "Quantile"), 
         new = c("D", "C", "B", "Q"))
data[, c("Name", "Functions") := NULL]

replace <- function(x) {
  x <- gsub("+", "y", x, fixed = TRUE)
  x <- gsub("-", "n", x, fixed = TRUE)
  return(x)
}

data$D <- replace(data$D)
data$C <- replace(data$C)
data$B <- replace(data$B)
data$Q <- replace(data$Q)

data <- data[, 1:6] %>%
  unique() 

data %>%
  kbl(format = "html",
      escape = FALSE,
      align = c("lccccl"),
      linesep = c('\\addlinespace')) %>%
  column_spec(1, width = "3.2cm") %>%
  column_spec(2, width = "1.5cm") %>%
  column_spec(3, width = "1.5cm") %>%
  column_spec(4, width = "1.3cm") %>%
  column_spec(5, width = "1.5cm") %>%
  column_spec(6, width = "6.0cm") %>%
  add_header_above(c(" " = 1, "Sample-based" = 2, "  " = 3)) %>%
  row_spec(seq(1, nrow(data), 2), background = "Gainsboro") %>%
  kable_styling()

## ----echo = FALSE, results = "asis"-------------------------------------------

data <- readRDS(
  system.file("metrics-overview/metrics-detailed.Rda", package = "scoringutils")
)

data[, 1:2] %>%
  kbl(format = "html",
      escape = TRUE) %>%
  column_spec(1, width = "3.5cm") %>%
  row_spec(seq(1, nrow(data), 2), background = "Gainsboro") %>%
  column_spec(2, width = "15.5cm") %>%
  kable_styling()

