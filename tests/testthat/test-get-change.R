
test_that("Grunnkrets without area code 00", {

  dt <- readRDS(system.file("test-data", "grks00-dt.rds", package = "norgeo"))
  dtout <- readRDS(system.file("test-data", "grks00-out.rds", package = "norgeo"))

  #TEST
  expect_equal(grunnkrets_00(dt), dtout)

})
