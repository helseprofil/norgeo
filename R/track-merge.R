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
  "kommune",
  "bydel",
  "grunnkrets"
),
from = NULL,
to = NULL) {
  type <- match.arg(type)
  dt <- track_change(type, from, to)
  data.table::setkey(dt, currentCode, changeOccurred)
  dt[!is.na(currentCode), merge := .N, by = data.table::rleid(changeOccurred, currentCode)]
  out <- dt[merge > 1]
}
