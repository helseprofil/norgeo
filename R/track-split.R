#' Get geo code that are split after code change
#'
#' @inheritParams get_code
#' @return Dataset of class `data.table` with column `split` showing the number
#'   of time the codes have been split to
#' @examples
#'  dt <- track_split("kommune", 2018, 2020)
#' @export

track_split <- function(type = c(
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
  dt <- track_change(type, from, to, fix = FALSE)[!is.na(oldCode)]
  data.table::setkey(dt, oldCode, changeOccurred)
  dt[, bycol := data.table::rleid(dt$changeOccurred, dt$oldCode)]
  dt[, split := .N, by = bycol]
  out <- dt[split > 1][, bycol := NULL]

  if (!names) out[, (granularityNames) := NULL][]

  return(out)
}
