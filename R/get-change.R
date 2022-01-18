#' Get geo code changes with API
#'
#' @description This function will download all geographical code changes from
#'   SSB via API except enumeration areas (\emph{grunnkrets}) between 1980 to
#'   2001. The code change can be found in the dataset `GrunnkretsBefore2002`.
#' @description Basically the downloaded data are those you can see directly
#'   \href{https://www.ssb.no/klass/klassifikasjoner/131/endringer}{here}, for
#'   example if you looking for code change in municipality (\emph{kommune}).
#'   The advantage of using \code{get_change} or
#'   \href{https://data.ssb.no/api/klass/v1/api-guide.html#_changes}{KLASS} is
#'   that you can get all code changes for several years at once.
#'
#' @param code TRUE will only track code changes. Else change name only will
#'   also be considered as change.
#' @param quiet TRUE will suppress messages when no changes happened for a
#'   specific time range
#' @inheritParams get_code
#' @return A dataset of class `data.table` consisting old and new code with
#'   the respective year when the codes have changed
#' @examples
#' DT <- get_change("kommune", from = 2018, to = 2020)
#' @export

get_change <- function(type = c(
                         "fylke",
                         "kommune",
                         "bydel",
                         "grunnkrets"
                       ),
                       from = NULL,
                       to = NULL,
                       code = TRUE,
                       quiet = FALSE,
                       date = FALSE) {

  inType <- length(type) > 1
  if (inType){
    stop(simpleError("Only one type og geographical levels is allowed"))
  }

  type <- match.arg(type)
  type <- grunnkrets_check(type, to)

  if (type == "bydel") {
    stop(simpleError("*** Change table for bydel is not available in SSB Klass API ***\n"))
  }

  klass <- switch(type,
    fylke = 104,
    kommune = 131,
    bydel = 103,
    grunnkrets = 1
  )

  if (is.null(from)) {
    from <- as.integer(format(Sys.Date(), "%Y"))
  }

  if (is.null(to)) {
    to <- as.integer(format(Sys.Date(), "%Y"))
  }

  check_range(from = from, to = to)

  baseUrl <- "http://data.ssb.no/api/klass/v1/classifications/"
  klsUrl <- paste0(baseUrl, klass)
  chgUrl <- paste0(klsUrl, "/changes")

  vecYr <- from:to
  nYr <- length(vecYr)

  ## reference table for from and to
  allRef <- data.table::CJ(1:nYr, 1:nYr)
  tblRef <- allRef[V2 - V1 == 1]

  ## Create empty list
  listDT <- vector(mode = "list", length = nrow(tblRef))

  for (i in seq_len(nrow(tblRef))) {

    indFrom <- tblRef$V1[i]
    indTo <- tblRef$V2[i]
    yrFrom <- vecYr[indFrom]
    yrTo <- vecYr[indTo]

    dateFrom <- set_year(yrFrom, FALSE)
    dateTo <- set_year(yrTo, TRUE)

    ## specify query
    chgQ <- list(from = dateFrom, to = dateTo)
    chgGET <- httr::RETRY("GET", url = chgUrl, query = chgQ)
    httr::warn_for_status(chgGET)
    chgTxt <- httr::content(chgGET, as = "text")

    chgJS <- tryCatch(
    {
      jsonlite::fromJSON(chgTxt)
    },
    error = function(err) {
      message(
        "*** Change table for ", type,
        " doesn't exist. From ", dateFrom, " to ", dateTo, " *** "
      )
    }
    )

    chgDT <- chgJS[[1]]
    data.table::setDT(chgDT)

    if (type == "grunnkrets"){
      chgDT <- grunnkrets_00(chgDT)
    }

    if (nrow(chgDT) > 0 && code) {
      chgDT <- chgDT[oldCode != newCode]
    }

    ## no error produced but table is empty
    if (quiet == 0 && !is.null(chgJS) && length(chgDT) == 0) {
      message("No code changes from ", dateFrom, " to ", dateTo, " or not available via API")
    }

    listDT[[i]] <- chgDT
  }

  cat("\n")
  DT <- data.table::rbindlist(listDT)

  ## need to create empty data.table when it's empty data from API
  if (nrow(DT) == 0) {
    colNs <- c(
      "oldCode",
      "oldName",
      "oldShortName",
      "newCode",
      "newName",
      "newShortName",
      "changeOccurred"
    )

    DT <- data.table::data.table(matrix(nrow = 0, ncol = 7))
    data.table::setnames(DT, new = colNs)
  }

  if (date == 0 && nrow(DT) != 0) {
    DT[, changeOccurred := format(as.Date(changeOccurred), "%Y")]
  }

  delCol <- c("oldShortName", "newShortName")
  DT[, (delCol) := NULL][]

  if (from < 2002){
    DT <- grunnkrets_before_2002(DT, type, from)
  }

  return(DT)
}


## to == FALSE is dateFrom and to == TRUE is dateTo
## dateTo should start at 02.jan because
## GET request for 'to' excludes the specified date in ssb.no KLASS API
set_year <- function(x, to = TRUE) {
  x <- as.character(x)
  dy <- paste0(x, "-01-01")

  ## valid codes for current from should NOT start with 01.jan
  is.errYr <- identical(format(Sys.Date(), "%m-%d"), "01-01")
  if (is.errYr || isTRUE(to)) {
    dy <- paste0(x, "-01-02")
  }

  ## now is TRUE if current year
  now <- identical(format(Sys.Date(), "%Y"), x)

  if (now) {
    dy <- Sys.Date() + 1
  }

  ## invisible(dy)
  return(dy)
}

grunnkrets_before_2002 <- function(dt, type, from = NULL){
  if (type == "grunnkrets"){
    message("Grunnkrets codes change before 2002 are from the dataset `GrunnkretsBefore2002`")
    gks <- norgeo::GrunnkretsBefore2002[changeOccurred %in% from:2001]
    gks <- grunnkrets_8digits(gks)
    gks <- grunnkrets_dirty(x = dt, y = gks)
    dt <- data.table::rbindlist(list(gks, dt), use.names = TRUE, fill = TRUE)
    dtCols <- c("oldCode", "oldName", "newCode", "newName", "changeOccurred")
    data.table::setcolorder(dt, dtCols)
  }

  return(dt)

}

## Ensure grunnkrets has 8 digits else add leading 0
grunnkrets_8digits <- function(dtg){
  digit1 <- digit2 <- NULL

  for (j in c("oldCode", "newCode")){
    data.table::set(dtg, j = j, value = as.character(dtg[[j]]))
  }

  dtg[, `:=`(digit1 = data.table::fifelse(nchar(oldCode) == 8, 0, 1),
             digit2 = data.table::fifelse(nchar(newCode) == 8, 0, 1)) ]

  dtg[digit1 == 1, oldCode := paste0("0", oldCode)]
  dtg[digit2 == 1, newCode := paste0("0", newCode)]

  dtg[, c("digit1", "digit2") := NULL]

  return(dtg)
}

## For unclean grunnkrets codes before 2002
## Se Issue #61
grunnkrets_dirty <- function(x, y){
  # x - dataset before 2002
  # y - dataset from GrunnkretsBefore2002
  codeOut <- intersect(unique(y$oldCode), unique(x$oldCode))
  y[!(oldCode %chin% codeOut)]
}

## Issue #65
## Area code ends with 00 sometimes aren't included in code change
## This make it standard that it will always be area codes
grunnkrets_00 <- function(x){

  grOld <- NULL

  if (nrow(x) == 0){
    return(x)
  }

  y <- copy(x)

  x[, "grOld" := gsub("\\d{2}$", "00", oldCode)]
  x[, "grNew" := gsub("\\d{2}$", "00", newCode)]

  grCodeOld <- unique(gsub("\\d{2}$", "00", unique(x$oldCode)))
  grCodeNew <- unique(gsub("\\d{2}$", "00", unique(x$newCode)))

  idxOld <- !is.element(grCodeOld, x$oldCode)
  idxNew <- !is.element(grCodeNew, x$newCode)

  idxOld <- grCodeOld[idxOld]
  idxNew <- grCodeOld[idxNew]

  x <- x[grOld %chin% idxOld][!duplicated(grOld)]
  colNames <- names(x)[-c(8,9)]
  cols <- c("oldCode", "newCode")
  x[, (cols) := NULL]
  data.table::setnames(x, c("grOld", "grNew"), cols)
  data.table::setcolorder(x, colNames)
  x[, c("oldName", "newName") := "Nothing from API"]

  x <- data.table::rbindlist(list(y, x))
  x[!duplicated(x)]
}
