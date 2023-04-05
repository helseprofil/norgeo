test_that("Track change", {
  dtOut <- readRDS(system.file("test-data", "trackChangeFylke_2017_2018.rds", package = "norgeo"))
  dtKomm <- readRDS(system.file("test-data", "trackChangeKomm_2010_2015.rds", package = "norgeo"))

  expect_equal(track_change("fylke", 2017, 2018), dtOut)
  expect_equal(track_change("kommune", 2010, 2015), dtKomm)
})

test_that("Track split", {
  dtOut <- readRDS(system.file("test-data", "split_2018_2020.rds", package = "norgeo"))
  expect_equal(track_split("k", 2018, 2020, names = FALSE), dtOut)
})

test_that("Track merge", {
  dtOut <- readRDS(system.file("test-data", "merge_2018_2020.rds", package = "norgeo"))
  expect_equal(track_merge("k", 2018, 2020), dtOut)
})
