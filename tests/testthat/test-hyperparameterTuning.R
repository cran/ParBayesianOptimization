context('Hyperparameter Tuning')

testthat::test_that(

  "xgboost"

  , {

    skip_on_cran()
    skip_if_not_installed("xgboost")
    library("xgboost")
    set.seed(0)

    data(agaricus.train, package = "xgboost")

    Folds <- list(
      Fold1 = as.integer(seq(1,nrow(agaricus.train$data),by = 3))
      , Fold2 = as.integer(seq(2,nrow(agaricus.train$data),by = 3))
      , Fold3 = as.integer(seq(3,nrow(agaricus.train$data),by = 3))
    )



    scoringFunction <- function(max_depth, max_leaves,
                                min_child_weight, subsample,
                                colsample_bytree, gamma, lambda, alpha,
                                .debug = FALSE) {

      # ---- Type coercion & scalarization ----
      max_depth        <- as.integer(max_depth)[1]
      max_leaves       <- as.integer(max_leaves)[1]
      min_child_weight <- as.numeric(min_child_weight)[1]
      subsample        <- as.numeric(subsample)[1]
      colsample_bytree <- as.numeric(colsample_bytree)[1]
      gamma            <- as.numeric(gamma)[1]
      lambda           <- as.numeric(lambda)[1]
      alpha            <- as.numeric(alpha)[1]

      # ---- Data (assumes 'agaricus.train' and 'Folds' exist) ----
      dtrain <- xgboost::xgb.DMatrix(
        data  = agaricus.train$data,
        label = agaricus.train$label
      )

      # Base params
      Pars <- list(
        booster           = "gbtree",
        eta               = 0.01,
        max_depth         = max_depth,
        min_child_weight  = min_child_weight,
        subsample         = subsample,
        colsample_bytree  = colsample_bytree,
        gamma             = gamma,
        lambda            = lambda,  # L2 reg
        alpha             = alpha,   # L1 reg
        objective         = "binary:logistic",
        eval_metric       = "auc"
      )

      # If max_leaves is requested, enable histogram/lossguide (so xgboost uses it)
      if (!is.na(max_leaves) && max_leaves > 0L) {
        Pars$tree_method <- "hist"
        Pars$grow_policy <- "lossguide"
        Pars$max_leaves  <- max_leaves
        # It's common to leave max_depth as-is; alternatively set max_depth = 0
        # Pars$max_depth <- 0L
      }

      # ---- Safe CV wrapper ----
      xgbcv <- try(
        xgboost::xgb.cv(
          params                 = Pars,
          data                   = dtrain,
          nrounds                = 100,
          folds                  = Folds,
          prediction             = FALSE,
          showsd                 = TRUE,
          early_stopping_rounds  = 5,
          maximize               = TRUE,
          verbose                = 0
        ),
        silent = TRUE
      )

      # On error: return worst score but keep scalars so bayesOpt can proceed
      if (inherits(xgbcv, "try-error")) {
        if (isTRUE(.debug)) message("xgb.cv error: ", as.character(xgbcv))
        return(list(Score = as.numeric(-Inf), BestNrounds = as.integer(1L)))
      }

      # ---- Scalar Score ----
      score_vec <- as.numeric(xgbcv$evaluation_log$test_auc_mean)
      if (!is.null(names(score_vec))) names(score_vec) <- NULL
      Score <- as.numeric(max(score_vec, na.rm = TRUE))[1]

      # ---- Scalar best nrounds ----
      bi <- xgbcv$best_iteration
      if (is.null(bi) || length(bi) != 1L || is.na(bi)) {
        bi <- which.max(score_vec)
        if (length(bi) != 1L || is.na(bi)) bi <- 1L
      }
      BestNrounds <- as.integer(bi)[1]

      if (isTRUE(.debug)) {
        cat(sprintf(
          "DEBUG | Score len=%d val=%.6f | BestNrounds len=%d val=%d\n",
          length(Score), Score, length(BestNrounds), BestNrounds
        ))
      }

      list(
        Score       = Score,        # must be scalar
        BestNrounds = BestNrounds   # must be scalar
      )
    }



    bounds <- list(
      max_depth = c(1L, 5L)
      , max_leaves = c(2L,25L)
      , min_child_weight = c(0, 25)
      , subsample = c(0.25, 1)
      , colsample_bytree = c(0.1,1)
      , gamma = c(0,1)
      , lambda = c(0,1)
      , alpha = c(0,1)
    )

    initGrid <- data.table(
      max_depth = c(1,1,2,2,3,3,4,4,5)
      , max_leaves = c(2,3,4,5,6,7,8,9,10)
      , min_child_weight = seq(bounds$min_child_weight[1],bounds$min_child_weight[2],length.out = 9)
      , subsample = seq(bounds$subsample[1],bounds$subsample[2],length.out = 9)
      , colsample_bytree = seq(bounds$colsample_bytree[1],bounds$colsample_bytree[2],length.out = 9)
      , gamma = seq(bounds$gamma[1],bounds$gamma[2],length.out = 9)
      , lambda = seq(bounds$lambda[1],bounds$lambda[2],length.out = 9)
      , alpha = seq(bounds$alpha[1],bounds$alpha[2],length.out = 9)
    )

    optObj <- bayesOpt(
      FUN = scoringFunction
      , bounds = bounds
      , initPoints = 9
      , iters.n = 4
      , iters.k = 1
      , gsPoints = 10
    )

    expect_equal(nrow(optObj$scoreSummary),13)

    optObj <- bayesOpt(
      FUN = scoringFunction
      , bounds = bounds
      , initGrid = initGrid
      , iters.n = 4
      , iters.k = 1
      , gsPoints = 10
    )

    expect_equal(nrow(optObj$scoreSummary),13)

  }

)
