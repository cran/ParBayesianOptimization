optObj <- structure(list(saveFile = NULL), class = "bayesOpt")

test_that("changeSaveFile() rejects objects that are not bayesOpt", {
  expect_error(changeSaveFile(list(), "x.rds"), "class bayesOpt")
})

test_that("changeSaveFile() rejects extensions other than .rds", {
  expect_error(changeSaveFile(optObj, "x.csv"), "file extension")
})

test_that("changeSaveFile() sets the save file", {
  expect_equal(changeSaveFile(optObj, "x.rds")$saveFile, "x.rds")
  expect_equal(changeSaveFile(optObj, "x.RDS")$saveFile, "x.RDS")
  expect_null(changeSaveFile(optObj, NULL)$saveFile)
})
