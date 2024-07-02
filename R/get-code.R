#' Get the codes of geographical levels
#'
#' This function will download the codes of selected geographical levels via API.
#'
#' @param type Type of regional granularity ie. fylke, kommune etc.
#' @param date Give complete date if TRUE else year only. Default it FALSE
#' @param names Include names. Default is TRUE
#' @inheritParams get_correspond
#' @return A dataset of class `data.table` consisting codes of selected
#'   geographical level and the duration the codes are valid ie. from and to.
#' @import data.table
#' @examples
#' mydata <- get_code("kommune", from = 2017, to = 2019)
#' @export

get_code <- function(type = c(
                       "fylke",
                       "okonomisk",
                       "kommune",
                       "bydel",
                       "levekaar",
                       "grunnkrets"
                     ),
                     from = NULL,
                     to = NULL,
                     date = FALSE,
                     names = TRUE) {
  ## globalVariables
  dateTo <- NULL

  type <- match.arg(type)

  klass <- switch(type,
    fylke = 104,
    okonomisk = 108,
    levekaar = 745,
    kommune = 131,
    bydel = 103,
    grunnkrets = 1
  )

  if (is.null(from)) {
    from <- date_now()
  } else {
    from <- paste0(from, "-01-01")
  }

  if (!is.null(to)) to <- paste0(to, "-01-02")
  base <- "http://data.ssb.no/api/klass/v1/classifications/"

  koDT <- set_url(
    base = base,
    from = from,
    to = to,
    klass = klass,
    source = "codes"
  )

  keepName <- c("code", "name")

  if (is.null(to)) {
    koDT[, setdiff(names(koDT), keepName) := NULL]
    koDT[, validTo := from][]
  } else {
    indN <- grep("InRequestedRange", names(koDT))
    valN <- names(koDT)[indN]
    koDT[, setdiff(names(koDT), c(keepName, valN)) := NULL][]
    data.table::setnames(koDT, old = valN, new = c("validFrom", "validTo"))
    data.table::setorderv(koDT, c("validTo", "code"))
  }

  if (base::isFALSE(date)) {
    dateVar <- c("validFrom", "validTo")
    selectCol <- dateVar[is.element(dateVar, names(koDT))]

    for (j in selectCol) {
      data.table::set(koDT, , j = j, value = format(as.Date(koDT[[j]]), "%Y"))
    }
  }

  if (!names)
    koDT[, "name" := NULL]

  return(koDT)
}

## base - What is base url
## source - Where the data is from eg. codesAt, corresponds etc
set_url <- function(base = NULL,
                    from = NULL,
                    to = NULL,
                    klass = NULL,
                    source = NULL) {
  baseUrl <- paste0(base, klass)

  if (is.null(to)) {
    sourceUrl <- paste0(source, "At.json")
    endUrl <- paste(baseUrl, sourceUrl, sep = "/")
    codeQry <- list(date = from)
  } else {
    sourceUrl <- paste0(source, ".json")
    endUrl <- paste(baseUrl, sourceUrl, sep = "/")
    codeQry <- list(from = from, to = to)
  }

  codeQry <- date_future(from = from, to = to, codeQry = codeQry)

  koReg <- httr2::request(endUrl) |>
    httr2::req_url_query(!!!codeQry) |>
    httr2::req_retry(max_tries = 5) |>
    httr2::req_perform()

  koDT <- koReg |> httr2::resp_body_json(simplifyDataFrame = TRUE)
  koDT <- data.table::as.data.table(koDT)

  koNames <- names(koDT)
  koNewNames <- gsub("^codes.", "", koNames)
  data.table::setnames(koDT, koNames, koNewNames)

  return(koDT)
}

## Ensure date is the required format
date_now <- function() {
  format(Sys.Date(), "%Y-%m-%d")
}

## date_warn <- function(to, future){

##   if (!future)
##     return(to)

##   dd <- data.table::year(date_now())
##   if (as.integer(to) > dd)
##     stop("Are you sure the year in `to` is corrent? Use arg `future = TRUE`")

##   invisible()
## }


## Depricated function
get_list <- function() {
  .Defunct("get_code")
}
