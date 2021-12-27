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
                          "kommune",
                          "bydel",
                          "grunnkrets"
                        ),
                        from = NULL,
                        to = NULL) {
  type <- match.arg(type)
  dt <- track_change(type, from, to)
  data.table::setkey(dt, oldCode, changeOccurred)
  dt[!is.na(oldCode), split := .N, by = data.table::rleid(changeOccurred, oldCode)]
  out <- dt[split > 1]
}
