fakeOptObj <- function(acq = "ucb") {
  structure(
    list(
      bounds = list(x = c(0, 1)),
      optPars = list(acq = acq),
      stopStatus = "OK",
      GauProList = list(gpUpToDate = FALSE),
      scoreSummary = data.table::data.table(
        x = c(0, 0.25, 0.5, 0.75, 1),
        Score = sin(3 * c(0, 0.25, 0.5, 0.75, 1)),
        Elapsed = c(1, 2, 3, 4, 5),
        inBounds = TRUE,
        errorMessage = NA_character_
      )
    ),
    class = "bayesOpt"
  )
}

test_that("updateGP() fits the score GP and marks it up to date", {
  optObj <- updateGP(fakeOptObj())

  expect_s4_class(optObj$GauProList$scoreGP, "km")
  expect_null(optObj$GauProList$timeGP)
  expect_true(optObj$GauProList$gpUpToDate)
})

test_that("updateGP() fits a time GP for eips", {
  optObj <- updateGP(fakeOptObj(acq = "eips"))

  expect_s4_class(optObj$GauProList$timeGP, "km")
})

test_that("updateGP() returns early when the GP is up to date", {
  optObj <- updateGP(fakeOptObj())

  expect_message(updateGP(optObj), "already up to date")
  expect_silent(updateGP(optObj, verbose = 0))
})

test_that("a km() error stops the process instead of failing", {
  optObj <- updateGP(fakeOptObj(), nugget = -1)

  expect_s3_class(optObj$stopStatus, "stopEarlyMsg")
  expect_match(optObj$stopStatus, "Error encountered while training GP")
  expect_false(optObj$GauProList$gpUpToDate)
})

test_that("updateGP() rejects arguments km() does not accept", {
  expect_error(updateGP(fakeOptObj(), foo = 1), "does not accept: foo")
})
