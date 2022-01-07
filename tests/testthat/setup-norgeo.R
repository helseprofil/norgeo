library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  dir = vcr::vcr_test_path("fixtures")
))
vcr::check_cassette_names()


## DATA --------------------------
## Code From To in get_code()
outDT <- readRDS(system.file("test-data", "codes-fromto.rds", package = "norgeo"))
