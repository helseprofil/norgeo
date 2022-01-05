test_that("get codes", {
  vcr::use_cassette("codes", {
    dt <- get_code(type = "grunnkrets", from = 2018, to = 2021)
  })

  outDT <- readRDS(system.file("test-data", "code.rds", package = "norgeo"))
  expect_equal(dt, outDT)

})
