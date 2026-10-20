fitGPs <- function() {
  design <- data.frame(x = c(0, 0.25, 0.5, 0.75, 1))
  list(
    score = DiceKriging::km(
      design = design,
      response = sin(3 * design$x),
      control = list(trace = 0)
    ),
    time = DiceKriging::km(
      design = design,
      response = c(0.2, 0.4, 0.6, 0.8, 1),
      control = list(trace = 0)
    ),
    y_max = max(sin(3 * design$x))
  )
}

par <- c(x = 0.6)
kappa <- 2.576
eps <- 0.01

acq <- function(gps, type, y_max = gps$y_max, k = kappa) {
  calcAcq(par, gps$score, gps$time, type, y_max, k, eps)
}

test_that("each acquisition function matches its formula", {
  gps <- fitGPs()
  pred <- predict(gps$score, data.frame(x = 0.6), type = "SK")
  timePred <- predict(gps$time, data.frame(x = 0.6), type = "SK")
  z <- (pred$mean - gps$y_max - eps) / pred$sd
  ei <- (pred$mean - gps$y_max - eps) * pnorm(z) + pred$sd * dnorm(z)

  expect_equal(acq(gps, "ucb"), pred$mean + kappa * pred$sd)
  expect_equal(acq(gps, "ei"), ei)
  expect_equal(acq(gps, "eips"), ei / timePred$mean)
  expect_equal(acq(gps, "poi"), pnorm(z))
})

test_that("acquisition functions behave as expected", {
  gps <- fitGPs()

  expect_gte(acq(gps, "ei"), 0)
  expect_gte(acq(gps, "poi"), 0)
  expect_lte(acq(gps, "poi"), 1)
  expect_gt(acq(gps, "ucb", k = 3), acq(gps, "ucb", k = 1))
  # y_max near the predicted mean, so neither value underflows to 0.
  expect_lt(acq(gps, "ei", y_max = 1), acq(gps, "ei", y_max = 0.9))
  expect_lt(acq(gps, "poi", y_max = 1), acq(gps, "poi", y_max = 0.9))
})
