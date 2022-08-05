#' Where downloaded data will be kept
#'
#' Downloaded data will be stored in dataApi to avoid downloading
#' multiple time for the same selected data
#' @export dataApi
#' @keywords internal

dataApi <- new.env()


#' @title Where raw data will be kept
#' @description Created object when running `norgeo::read_csv()`
#' @export raw
#' @keywords internal

raw <- new.env()
