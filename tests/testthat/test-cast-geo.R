test_that("Cast geo", {
  dt <- readRDS(system.file("test-data", "cast_2010.rds", package = "norgeo"))

  expect_equal(cast_geo(2010), dt)
})
