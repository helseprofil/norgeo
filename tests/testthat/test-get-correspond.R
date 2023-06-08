
test_that("get correspond - all", {
  vcr::use_cassette("correspond", {
    dt <- get_correspond(type = "fylke", correspond = "kommune", from = 2016, to = 2018, names = F)
  })

  expect_equal(dt, dtCorr)
})

