test_that("Track change", {
  dtOut <- readRDS(system.file("test-data", "trackChangeFylke_2018_2020.rds", package = "norgeo"))

  expect_equal(track_change("fylke", 2018, 2020), dtOut)
})
