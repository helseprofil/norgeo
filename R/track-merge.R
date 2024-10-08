#' Get geo code that are merged after code change
#'
#' @inheritParams get_code
#' @return Dataset of class `data.table` with column `merge` showing the number
#'   of time the codes have been merged into
#' @examples
#'  dt <- track_merge("kommune", 2018, 2020)
#' @export
track_merge <- function(type = c(
  "fylke",
  "okonomisk", 
  "kommune",
  "bydel",
  "levekaar",
  "grunnkrets"
),
from = NULL,
to = NULL,
names = TRUE) {
  type <- match.arg(type)
  dt <- track_change(type, from, to, fix = FALSE)
  data.table::setkey(dt, currentCode, changeOccurred)
  dt[!is.na(currentCode), bycol := data.table::rleid(changeOccurred, currentCode)]
  dt[!is.na(currentCode), merge := .N, by = bycol]
  out <- dt[merge > 1][, bycol := NULL]

  if (!names)
    out[, (granularityNames) := NULL]

  return(out)
}
