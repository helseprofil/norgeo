library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  dir = vcr::vcr_test_path("fixtures")
))
vcr::check_cassette_names()


## DATA --------------------------
## Code From To in get_code()
outDT <- readRDS(system.file("test-data", "codes-fromto.rds", package = "norgeo"))

## get_change() -----
## chgDT <- get_change(type = "fylke", from = 2018, to = 2020)
## saveRDS(chgDT, file.path(system.file("test-data", package = "norgeo"), "change-dt.rds"))
chgDT <- readRDS(system.file("test-data", "change-dt.rds", package = "norgeo"))

## Correspond --------------------
## dtCorr <- get_correspond("fylke", "kommune", from = 2018, to = 2020)
## saveRDS(dtCorr, file.path(system.file("test-data", package = "norgeo"), "dtCorres.rds"))
dtCorr <- readRDS(system.file("test-data", "dtCorres.rds", package = "norgeo"))
