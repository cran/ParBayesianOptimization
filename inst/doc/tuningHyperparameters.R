## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
backup_options <- options()
options(width = 1000)
set.seed(1991)
xgbAvail <- requireNamespace('xgboost', quietly = TRUE)













## ----revert_options, include=FALSE--------------------------------------------
options(backup_options)

