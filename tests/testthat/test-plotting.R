test_that("plot() stacks the score and utility plots", {
  optObj <- structure(
    list(
      optPars = list(acq = "ucb"),
      scoreSummary = data.table::data.table(
        Epoch = c(0, 0, 1, 2),
        Score = c(1, 2, 3, 2.5),
        gpUtility = c(NA, NA, 0.8, 0.6),
        acqOptimum = c(FALSE, FALSE, TRUE, TRUE)
      )
    ),
    class = "bayesOpt"
  )

  p <- plot(optObj)

  expect_s3_class(p, "patchwork")
  expect_length(p, 2)
})

test_that("plot() arguments override the layout defaults", {
  optObj <- structure(
    list(
      optPars = list(acq = "ucb"),
      scoreSummary = data.table::data.table(
        Epoch = c(0, 0, 1, 2),
        Score = c(1, 2, 3, 2.5),
        gpUtility = c(NA, NA, 0.8, 0.6),
        acqOptimum = c(FALSE, FALSE, TRUE, TRUE)
      )
    ),
    class = "bayesOpt"
  )

  # patchwork has no public accessor for the layout, so read it directly.
  layout <- function(p) p$patches$layout
  expect_equal(layout(plot(optObj))$ncol, 1)
  expect_equal(layout(plot(optObj, ncol = 2, guides = "keep"))$ncol, 2)
  expect_equal(layout(plot(optObj, ncol = 2, guides = "keep"))$guides, "keep")
  expect_equal(layout(plot(optObj, nc = 2))$ncol, 2)
  expect_equal(layout(plot(optObj, 2))$nrow, 2)
})

test_that("plotProgress = TRUE plots during the run", {
  skip_on_cran()
  set.seed(0)

  FUN <- function(x, y) list(Score = 1000 - (x - 5)^2 - (y + 10)^2)
  bounds <- list(x = c(0, 15), y = c(-20, 100))

  expect_no_error(
    bayesOpt(
      FUN,
      bounds,
      initPoints = 4,
      iters.n = 2,
      plotProgress = TRUE,
      verbose = 0
    )
  )
})
