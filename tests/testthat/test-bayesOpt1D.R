test_that("1 Input, Different Specifications", {
  skip_on_cran()

  set.seed(1991)
  sf <- function(x) 100 - x^2 / 5
  FUN <- function(x) {
    return(list(Score = sf(x)))
  }
  bounds <- list(
    x = c(-2, 2)
  )
  optObj <- bayesOpt(
    FUN,
    bounds,
    initPoints = 4,
    iters.n = 2,
    verbose = 0
  )
  expect_equal(optObj$stopStatus, "OK")
  expect_equal(nrow(optObj$scoreSummary), 6)

  # Test adding Iterations
  optObj <- addIterations(
    optObj,
    iters.n = 2,
    verbose = 0,
    gsPoints = 10
  )

  # Test adding iterations with higher iters.k and different bounds
  newBounds <- list(x = c(-2, 8))
  optObj <- addIterations(
    optObj,
    bounds = newBounds,
    iters.n = 6,
    iters.k = 2,
    verbose = 0,
    gsPoints = 10
  )

  print(optObj)

  expect_equal(nrow(optObj$scoreSummary), 14)
})

test_that("bayesOpt() leaves the user's sinks open", {
  skip_on_cran()
  skip_if_not_installed("withr")

  log <- withr::local_tempfile()
  outerSinks <- sink.number()
  sink(log)
  withr::defer(
    while (sink.number() > outerSinks) {
      sink()
    }
  )

  bayesOpt(
    function(x) list(Score = -x^2),
    list(x = c(-2, 2)),
    initPoints = 3,
    iters.n = 1,
    verbose = 0
  )
  cat("after bayesOpt\n")
  sink()

  expect_equal(readLines(log), "after bayesOpt")
})

test_that("tighter bounds in addIterations() warn and exclude rows from the GP", {
  skip_on_cran()
  set.seed(1991)

  optObj <- bayesOpt(
    function(x) list(Score = -x^2),
    list(x = c(-5, 5)),
    initGrid = data.frame(x = c(-5, -4, -1, 0, 1, 4)),
    iters.n = 1,
    verbose = 0
  )

  expect_warning(
    optObj <- addIterations(
      optObj,
      bounds = list(x = c(-3, 3)),
      iters.n = 1,
      verbose = 0
    ),
    "Bounds have been tightened"
  )
  expect_equal(optObj$stopStatus, "OK")
  expect_equal(nrow(optObj$scoreSummary), 8)

  fitRows <- optObj$scoreSummary[1:7]
  expect_equal(fitRows$inBounds, abs(fitRows$x) <= 3)
  expect_equal(optObj$GauProList$scoreGP@n, sum(fitRows$inBounds))
})

test_that("the tightened-bounds warning matches the number of rows", {
  skip_on_cran()
  set.seed(1991)

  optObj <- bayesOpt(
    function(x) list(Score = -x^2),
    list(x = c(-5, 5)),
    initGrid = data.frame(x = c(-5, -4, -1, 0, 1, 4)),
    iters.n = 1,
    verbose = 0
  )
  outside <- function(lower) sum(optObj$scoreSummary$x < lower)
  expect_equal(outside(-4.5), 1)
  expect_equal(outside(-3.5), 2)

  expect_warning(
    addIterations(
      optObj,
      bounds = list(x = c(-4.5, 5)),
      iters.n = 1,
      verbose = 0
    ),
    "1 parameter set in scoreSummary is outside",
    fixed = TRUE
  )
  expect_warning(
    addIterations(
      optObj,
      bounds = list(x = c(-3.5, 5)),
      iters.n = 1,
      verbose = 0
    ),
    "2 parameter sets in scoreSummary are outside",
    fixed = TRUE
  )
})

test_that("addIterations() refits a GP that was up to date when bounds change", {
  skip_on_cran()
  set.seed(1991)

  optObj <- bayesOpt(
    function(x) list(Score = -x^2),
    list(x = c(-5, 5)),
    initGrid = data.frame(x = c(-5, -4, -1, 0, 1, 4)),
    iters.n = 1,
    verbose = 0
  )
  optObj <- updateGP(optObj, verbose = 0)
  expect_equal(optObj$GauProList$scoreGP@n, 7)

  # iters.n = 0 would fail checkParameters(); iters.n = 1 adds one row after
  # the GP is fitted.
  suppressWarnings(
    optObj <- addIterations(
      optObj,
      bounds = list(x = c(-3, 3)),
      iters.n = 1,
      verbose = 0
    )
  )
  expect_equal(
    optObj$GauProList$scoreGP@n,
    sum(abs(optObj$scoreSummary$x[1:7]) <= 3)
  )
})

test_that("addIterations() needs 3 usable samples within bounds", {
  skip_on_cran()

  optObj <- bayesOpt(
    function(x) list(Score = -x^2),
    list(x = c(-5, 5)),
    initGrid = data.frame(x = c(-5, -4, 0, 4)),
    iters.n = 1,
    verbose = 0
  )

  expect_error(
    suppressWarnings(addIterations(optObj, bounds = list(x = c(-1, 1)))),
    "within bounds are needed"
  )
})
