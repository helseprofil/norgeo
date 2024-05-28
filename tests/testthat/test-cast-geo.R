test_that("Cast geo", {
  dt <- readRDS(system.file("test-data", "cast_2024.rds", package = "norgeo"))
  dt[, name := NULL]
  setkeyv(dt, "kommune")

  expect_equal(cast_geo(2024, names = FALSE), dt)
})
