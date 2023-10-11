test_that("Alter geo manually", {

  ## altOut <- readRDS(system.file("test-data", "alter-manual.rds", package = "norgeo"))
  ## expect_equal(alter_manual(data.table::copy(chgDT), 9999), altOut)
  ## expect_equal(is_delete_index(data.table::copy(chgDT), c(6, 7)), altOut)
  expect_false(check_url("https://www.nothing.bla.bla"))
  expect_true(check_url("https://www.ap.no"))
})
