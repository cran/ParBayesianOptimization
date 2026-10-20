FUN <- function(x, y) list(Score = -(x^2 + y^2))
bounds <- list(x = c(-1, 1), y = c(-1, 1))

test_that("bayesOpt() needs exactly one of initGrid and initPoints", {
  grid <- data.frame(x = c(-1, 0, 1), y = c(0, 1, -1))

  expect_error(bayesOpt(FUN, bounds, verbose = 0), "not both")
  expect_error(
    bayesOpt(FUN, bounds, initGrid = grid, initPoints = 3, verbose = 0),
    "not both"
  )
})

test_that("bayesOpt() rejects bad initial grids", {
  outside <- data.frame(x = c(-1, 0, 2), y = c(0, 1, -1))
  small <- data.frame(x = c(-1, 1), y = c(0, 1))

  expect_error(
    bayesOpt(FUN, bounds, initGrid = outside, verbose = 0),
    "initGrid not within bounds"
  )
  expect_error(
    bayesOpt(FUN, bounds, initGrid = small, verbose = 0),
    "less than 3 samples"
  )
  expect_error(
    bayesOpt(FUN, bounds, initPoints = 2, verbose = 0),
    "less than 3 samples"
  )
  expect_error(
    bayesOpt(
      function(x, y, z) list(Score = x + y + z),
      list(x = c(0, 1), y = c(0, 1), z = c(0, 1)),
      initPoints = 3,
      verbose = 0
    ),
    "greater than the number of FUN inputs"
  )
})

test_that("bayesOpt() stops when FUN returns a malformed result", {
  init <- function(f) bayesOpt(f, bounds, initPoints = 3, verbose = 0)

  expect_error(init(function(x, y) x + y), "was not a list")
  expect_error(init(function(x, y) list(Value = x)), "element 'Score'")
  expect_error(init(function(x, y) list(Score = "a")), "was not numeric")
  expect_error(
    init(function(x, y) list(Score = x, Extra = 1:2)),
    "length > 1: Extra"
  )
})

test_that("addIterations() rejects objects it cannot continue", {
  optObj <- structure(
    list(
      FUN = FUN,
      bounds = bounds,
      saveFile = NULL,
      optPars = list(
        acq = "ucb",
        kappa = 2.576,
        eps = 0,
        gsPoints = 10,
        convThresh = 1e8,
        acqThresh = 1
      ),
      scoreSummary = data.table::data.table(
        Epoch = 0,
        x = c(0, 0.5),
        y = c(0, 0.5),
        Score = c(0, -0.5),
        inBounds = TRUE,
        errorMessage = NA_character_
      )
    ),
    class = "bayesOpt"
  )

  expect_error(addIterations(unclass(optObj)), "must be of class bayesOpt")
  expect_error(addIterations(optObj, verbose = 0), "Not enough samples")
})

test_that("misspelled arguments are caught before FUN runs", {
  calls <- 0
  countingFUN <- function(x, y) {
    calls <<- calls + 1
    list(Score = -(x^2 + y^2))
  }

  expect_error(
    bayesOpt(countingFUN, bounds, initPoints = 3, iter.n = 2, verbose = 0),
    "does not accept: iter.n"
  )
  expect_equal(calls, 0)
  expect_error(checkKmArgs(1), "<unnamed>")
  expect_no_error(checkKmArgs(nugget = 1e-8, covtype = "gauss"))
  expect_no_error(checkKmArgs(covt = "gauss", noise = rep(0.1, 3)))
  expect_error(checkKmArgs(nug = 1e-8), "does not accept: nug")
  expect_error(checkKmArgs(co = 1), "does not accept: co")
  expect_error(checkKmArgs(control = list()), "already supplied or set")
  expect_error(
    checkKmArgs(covtype = "gauss", covt = "exp"),
    "control): covt",
    fixed = TRUE
  )
  expect_no_error(checkKmArgs(nugget = 1e-8, nug = TRUE))
})

test_that("bayesOpt() accepts only exact acq names", {
  for (acq in list("foo", "eip", NULL, c("ucb", "ei"))) {
    expect_error(
      bayesOpt(FUN, bounds, initPoints = 3, acq = acq, verbose = 0),
      "Acquisition function not recognized"
    )
  }
})
