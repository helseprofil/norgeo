test_that("Track change", {
  dtOut <- readRDS(system.file("test-data", "trackChangeFylke_2018_2020.rds", package = "norgeo"))
  dtKomm <- readRDS(system.file("test-data", "trackChangeKomm_2017_2020.rds", package = "norgeo"))

  expect_equal(track_change("fylke", 2018, 2020), dtOut)
  expect_equal(track_change("kommune", 2017, 2020), dtKomm)
})
