
test_that("get correspond - all", {
  vcr::use_cassette("correspond", {
    dt <- get_correspond(type = "fylke", correspond = "kommune", from = 2018, to = 2020)
  })

  expect_equal(dt, dtCorr)
})

