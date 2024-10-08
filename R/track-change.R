#' Track all changes for codes from API
#'
#' Track all code changes until current year or the year specified in \code{to} argument.
#' The column \code{oldCode} could have several codes if it has changed many times until
#' it becomes the code in \code{newCode}. When no code change has taken place, \code{NA} will
#' be used.
#'
#' @inheritParams get_code
#' @param fix Default is FALSE. When TRUE then use external codes to fix geo
#'   changes manually. The codes is sourced from
#'   \href{https://github.com/helseprofil/config/tree/main/geo}{config} files
#'   depending on the granularity levels.
#' @return A dataset of class `data.table` consisting all older codes from
#'   previous years until the selected year in `to` argument and what these
#'   older codes were changed into. If the codes have not changed then the value
#'   of old code will be `NA`.
#'
#' @examples
#' mydata <- track_change("kommune", from = 2017, to = 2018)
#'
#' @import data.table
#'
#' @export
track_change <- function(type = c(
                           "fylke",
                           "okonomisk",
                           "kommune",
                           "bydel",
                           "levekaar",
                           "grunnkrets"
                         ),
                         from = NULL,
                         to = NULL,
                         names = TRUE,
                         fix = FALSE) {

  type <- match.arg(type)
  type <- grunnkrets_check(type, to)

  data_change(type, from, to)

  if (nrow(dataApi$dc) == 0) {
    stop("No code change has occurred for the selected time range")
  }

  ## Prepare the starting dataset with current year vs. last year
  data_current(type, to)

  vecYear <- unique(dataApi$dc$changeOccurred)
  selYear <- sort(vecYear[vecYear != dataApi$yrMax], decreasing = TRUE)

  for (i in seq_along(selYear)) {
    dataApi$dt <- data_merge(dataApi$dt, dataApi$dc, selYear[i])
  }

  data.table::setkey(dataApi$dt, newCode, changeOccurred)
  ## When nothing changes
  dataApi$dt[oldCode == newCode, oldCode := NA]
  data.table::setnames(dataApi$dt, "newCode", "currentCode")
  DT <- data.table::copy(dataApi$dt[])

  if (!names)
    DT[, (granularityNames) := NULL]

  if (fix){
    DT <- alter_manual(DT, type)
  } else {
    message("Please check splitting geo codes with `track_split()` for possible error")
    message("Use `fix = TRUE` to implement the way we do it in our work. Please read the documentation")
  }

  return(DT)
}

## HELPER --------------------------------------

## Do testing with:
## dat <- data_current()
## length(unique(dat$changeOccurred))==2
## Else there isn't any changes occurred
data_current <- function(type, to) {
  if (is.null(to)) {
    to <- as.integer(format(Sys.Date(), "%Y"))
  }

  DT <- get_code(type = type, from = to)

  ## dataApi$dc is created when data_change is called in function track_change
  yrMax <- max(dataApi$dc$changeOccurred)
  dataApi$yrMax <- yrMax

  dt <- dataApi$dc[changeOccurred == yrMax][DT, on = c(newCode = "code")]

  ## when no code changes have occurred except names
  dt[is.na(oldCode), oldCode := newCode][
    is.na(changeOccurred), changeOccurred := validTo][
      is.na(newName), newName := name]

  dt[, c("name", "validTo") := NULL][]
  dataApi$dt <- dt
}

## data1 : newest dataset with code changes
## data2 : older dataset with code changes
## year  : year for subset
data_merge <- function(data1, data2, year) {

  ## 1 to 1 merge
  dtc <- data1[data2[changeOccurred == year], on = c(oldCode = "newCode")]
  delCols <- c("oldCode", "oldName", "i.newName", "changeOccurred")
  dtc[, (delCols) := NULL]
  data.table::setnames(
    dtc,
    c("i.oldCode", "i.oldName", "i.changeOccurred"),
    c("oldCode", "oldName", "changeOccurred")
  )

  ## Code changes that happen multiple time at different years while keeping the newest code
  ## eg. Trondheim in 2018 and Klæbu joining Trondheim in 2020
  codeMulti <- dtc[is.na(newCode)]$oldCode

  if (length(codeMulti) > 0) {
    dtp <- data1[data2[oldCode %in% codeMulti], on = "newCode"]
    delCols <- c("oldCode", "oldName", "newName", "changeOccurred")
    dtp[, (delCols) := NULL]
    data.table::setnames(
      dtp,
      c("i.oldCode", "i.changeOccurred", "i.oldName", "i.newName"),
      c("oldCode", "changeOccurred", "oldName", "newName")
    )

    dtcNA <- dtc[!is.na(newCode)]

    DTC <- data.table::rbindlist(list(dtcNA, dtp), use.names = TRUE)
  } else {
    DTC <- dtc
  }

  dd <- data.table::rbindlist(list(data1, DTC), use.names = TRUE)
}


## Avoid downloading changes data multiple times
data_change <- function(type, from, to) {
  dataApi$dc <- get_change(
    type = type,
    from = from,
    to = to,
    quiet = TRUE
  )
}

grunnkrets_check <- function(type, to = NULL){
  if (is.null(to)) {
    to <- as.integer(format(Sys.Date(), "%Y"))
  }

  if (type == "grunnkrets" && to < 2003){
    stop(simpleError("For grunnkrets code change up to 2001, use data `GrunnkretsBefore2002`"))
  }

  invisible(type)
}

## Maually alter dataset especially when there are splitting codes ie. issue 84
## Codes should be in config repo file
alter_manual <- function(DT, type){

  baseURL <- "https://raw.githubusercontent.com/helseprofil/backend/main/norgeo/"

  fileName <- switch(type,
                     fylke = "geo-fylke.R",
                     kommune = "geo-kommune.R",
                     bydel = "geo-bydel.R",
                     grunnkrets = "geo-grunnkrets.R"
                     )

  http <- paste0(baseURL, fileName)

  if (check_url(http)){
    message("Run source file ", http)
    source(http, local = TRUE)
  }

  return(DT)
}

check_url <- function(http){
  con <- url(http)
  check <- suppressWarnings(try(open.connection(con, open = "rt", timeout = TRUE), silent = TRUE))
  suppressWarnings(try(close.connection(con),silent=TRUE))
  ifelse(is.null(check),TRUE,FALSE)
}
