test_that("get code at", {
  dtOut <- readRDS(system.file("test-data", "codeAt.rds", package = "norgeo"))
  expect_equal(get_code(type = "fylke", 2018), dtOut)
})

# test_that("get codes - all", {
#   vcr::use_cassette("codes-fromto", {
#     dt <- get_code(type = "fylke", from = 2016, to = 2018, names = F)
#   })
# 
#   expect_equal(dt, outDT)
# })

