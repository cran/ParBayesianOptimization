checkArgs <- function(...) {
  args <- list(
    bounds = list(x = c(0, 1)),
    iters.n = 4,
    iters.k = 2,
    otherHalting = list(timeLimit = Inf, minUtility = 0),
    acq = "ucb",
    acqThresh = 0.9,
    errorHandling = "stop",
    plotProgress = FALSE,
    parallel = FALSE,
    verbose = 0
  )
  do.call(checkParameters, utils::modifyList(args, list(...)))
}

test_that("valid parameters pass", {
  expect_no_error(checkArgs())
  expect_no_error(checkArgs(errorHandling = "continue"))
  expect_no_error(checkArgs(errorHandling = 3))
})

test_that("invalid parameters are errors", {
  expect_error(checkArgs(iters.n = 1), "iters.n cannot be less than iters.k")
  expect_error(checkArgs(iters.n = 4.5), "must be integers")
  expect_error(checkArgs(iters.k = 1.5), "must be integers")
  expect_error(checkArgs(acq = "foo"), "Acquisition function not recognized")
  expect_error(
    checkArgs(acq = c("ucb", "ei")),
    "Acquisition function not recognized"
  )
  expect_error(
    checkArgs(acq = NA_character_),
    "Acquisition function not recognized"
  )
  expect_error(
    checkArgs(otherHalting = list(foo = 1)),
    "otherHalting element not recognized"
  )
  expect_error(checkArgs(bounds = c(x = 1)), "bounds must be a list")
  expect_error(checkArgs(bounds = list(x = c(0, 1, 2))), "length 2")
  expect_error(checkArgs(acqThresh = 1.5), "acqThresh must be in")
  expect_error(checkArgs(acqThresh = -0.1), "acqThresh must be in")
  expect_error(checkArgs(plotProgress = "yes"), "plotProgress must be logical")
  expect_error(checkArgs(errorHandling = "foo"), "errorHandling is malformed")
})

test_that("parallel = TRUE needs a registered backend", {
  local_mocked_bindings(getDoParWorkers = function() 1)
  expect_error(checkArgs(parallel = TRUE), "no back end is registered")
})
