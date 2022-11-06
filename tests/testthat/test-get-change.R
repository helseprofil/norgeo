test_that("Grunnkrets from before 2002", {

  dtOut <- readRDS(system.file("test-data", "grChg_1999_2003.rds", package = "norgeo"))
  expect_equal(get_change("g", 1999, 2003), dtOut)
})

test_that("Grunnkrets without area code 00", {

  dt <- readRDS(system.file("test-data", "grks00-dt.rds", package = "norgeo"))
  dtout <- readRDS(system.file("test-data", "grks00-out.rds", package = "norgeo"))

  #TEST
  expect_equal(grunnkrets_00(dt), dtout)

})


test_that("get change - all", {
  vcr::use_cassette("change", {
    dt <- get_change(type = "fylke", from = 2018, to = 2020)
  })

  expect_equal(dt, chgDT)
})

test_that("Valid date year", {
  expect_equal(set_year(2021, TRUE), "2021-01-02")
  expect_equal(set_year(2021, FALSE), "2021-01-01")
})
