test_that("Cast geo", {
  dt <- readRDS(system.file("test-data", "cast_2010.rds", package = "norgeo"))
  dt[, name := NULL]

  expect_equal(cast_geo(2010, names = FALSE), dt)
})
