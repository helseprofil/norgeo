
test_that("get correspond - all", {
  vcr::use_cassette("correspond", {
    dt <- get_correspond(type = "fylke", correspond = "kommune", from = 2018, to = 2020)
  })

  expect_equal(dt, dtCorr)
})

test_that("get correspond - error", {
  vcr::skip_if_vcr_off()
  vcr::use_cassette("correspond-error", {
    expect_error( get_correspond(type = "fylke", correspond = "kommune", from = 2018, to = 2020))
  })
})

test_that("get correspond - retry", {
  vcr::skip_if_vcr_off()
  vcr::use_cassette("correspond-retry", {
    dt <- get_correspond(type = "fylke", correspond = "kommune", from = 2018, to = 2020)
  })
  expect_equal(dt, dtCorr)
})
