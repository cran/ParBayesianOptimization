## ----setup, include = FALSE---------------------------------------------------
backup_options <- options()
options(width = 1000)
set.seed(1991)
xgbAvail <- requireNamespace('xgboost', quietly = TRUE) &&
  utils::packageVersion('xgboost') >= '3.0.0'













## ----revert_options, include=FALSE--------------------------------------------
options(backup_options)

