test_that("Cast geo", {
  dt <- readRDS(system.file("test-data", "cast_2024b.rds", package = "norgeo"))
  dt[, name := NULL]
  setkey(dt, code)

  expect_equal(cast_geo(2024, names = FALSE), dt)
})
