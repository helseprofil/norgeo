test_that("get code at", {
  dtOut <- readRDS(system.file("test-data", "codeAt.rds", package = "norgeo"))
  expect_equal(get_code(type = "fylke", 2018), dtOut)
})

test_that("get codes - all", {
  vcr::use_cassette("codes-fromto", {
    dt <- get_code(type = "fylke", from = 2018, to = 2020)
  })

  expect_equal(dt, outDT)
})


test_that("get codes - error", {
  vcr::skip_if_vcr_off()
  vcr::use_cassette("codes-fromto-error", {
    expect_error(get_code(type = "grunnkrets", from = 2018, to = 2021))
  })
})

test_that("get codes - retry", {
  vcr::skip_if_vcr_off()
  vcr::use_cassette("codes-fromto-retry", {
    expect_message(dts <- get_code(type = "fylke", from = 2018, to = 2020), "try")
  })

  expect_equal(dts, outDT)
})
