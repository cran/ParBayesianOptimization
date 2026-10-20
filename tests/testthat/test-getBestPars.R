fakeOptObj <- function() {
  structure(
    list(
      bounds = list(x = c(0, 10), y = c(0, 10)),
      scoreSummary = data.table::data.table(
        Epoch = c(0, 0, 1),
        Iteration = 1:3,
        x = c(1, 2, 3),
        y = c(4, 5, 6),
        Score = c(0.5, 2, 1)
      )
    ),
    class = "bayesOpt"
  )
}

test_that("N = 1 returns the best parameters as a named list", {
  expect_equal(getBestPars(fakeOptObj()), list(x = 2, y = 5))
})

test_that("N > 1 returns a data.table ordered by descending Score", {
  best <- getBestPars(fakeOptObj(), N = 2)

  expect_s3_class(best, "data.table")
  expect_named(best, c("x", "y"))
  expect_equal(best$x, c(2, 3))
})

test_that("N larger than the number of runs is an error", {
  expect_error(getBestPars(fakeOptObj(), N = 4), "N is greater")
})
