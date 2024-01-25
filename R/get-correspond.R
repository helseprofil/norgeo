#' Get geo corresponds
#'
#' This function will get the corresponding geo code of specific granularity via
#' API from SSB whenever available.
#'
#' @param type Higher granularity from specified correspond arg.
#' @param correspond Lower granularity from the specified type arg.
#' @param from Specify the starting year for range period. Current year is the
#'   default.
#' @param to Specify the year to end the range period. Current year is used when
#'   not specified.
#' @param dt Output as data.table
#' @inheritParams get_code
#' @return A dataset of class `data.table` representing the lower geographical
#'   level codes and their corresponding higher geographical levels. For example
#'   for codes on enumeration areas and their corresponding codes for
#'   municipalities or town.
#' @examples
#' df <- get_correspond("kommune", "grunnkrets", 2019)
#'
#' @export

get_correspond <- function(type = c(
                             "fylke",
                             "kommune",
                             "bydel"
                           ),
                           correspond = c(
                             "fylke",
                             "kommune",
                             "bydel",
                             "grunnkrets"
                           ),
                           from = NULL,
                           to = NULL,
                           dt = TRUE,
                           names = TRUE) {
  type <- match.arg(type)

  klass <- switch(type,
    fylke = 104,
    kommune = 131,
    bydel = 103,
    grunnkrets = 1
  )

  correspond <- match.arg(correspond)
  corr <- switch(correspond,
    fylke = 104,
    kommune = 131,
    bydel = 103,
    grunnkrets = 1
  )

  ## trueType <- klass %in% c(103, 131)
  if (klass %in% c(103, 131) && corr != 1) {
    stop("`Correspond` arg should be lower granularity than `type` arg,\n  or requested combination is not available in SSB")
  }

  if (klass == 104 && corr != 131) {
    stop("Use `kommune` to get correspond table for `fylke`!")
  }

  baseUrl <- "http://data.ssb.no/api/klass/v1/classifications/"
  klsUrl <- paste0(baseUrl, klass)

  if (is.null(from)) {
    year <- as.character(format(Sys.Date(), "%Y"))
    from <- paste0(year, "-01-01")
  } else {
    from <- paste0(from, "-01-01")
  }

  ## must start from 02 of the month as in API requirement
  if (!is.null(to)) to <- paste0(to, "-01-02")

  x <- tryCatch({
    set_corr(
      from = from,
      to = to,
      id = corr,
      url = klsUrl,
      dt = dt
    )},
    error = function(err) err
    )

  if (inherits(x, "error") && type != "bydel"){
    z <- make_corr(
      type = type,
      correspond = correspond,
      from = from,
      to = to
    )
  } else {
    z <- x
  }

  if (!names)
    z[, c("sourceName", "targetName") := NULL]

  return(z[])
}


set_corr <- function(from = NULL,
                     to = NULL,
                     id = NULL,
                     url = NULL,
                     dt = TRUE) {
  if (is.null(to)) {
    corrUrl <- paste0(url, "/correspondsAt.json")
    codeQry <- list(targetClassificationId = id, date = from)
  } else {
    corrUrl <- paste0(url, "/corresponds.json")
    codeQry <- list(targetClassificationId = id, from = from, to = to)
  }

  codeQry <- date_future(from = from, to = to, codeQry = codeQry)

  koReg <- httr2::request(corrUrl) |>
    httr2::req_url_query(!!!codeQry) |>
    httr2::req_retry(max_tries = 5) |>
    httr2::req_perform()

  koDT <- koReg |> httr2::resp_body_json(simplifyDataFrame = TRUE)
  koDT <- data.table::as.data.table(koDT)

  colx <- names(koDT)
  cols <- gsub("^correspondenceItems\\.", "", colx)
  data.table::setnames(koDT, colx, cols)

  if (dt) {
    data.table::setDT(koDT)
  }

  return(koDT)
}


# make correspond table manually for kommune and fylke when
# correspond table doens't exist
make_corr <- function(type, correspond, from, to){
  sourceCode <- sourceName <- i.name <- NULL

  message("Correspond table not found! Manually created table will be used...\n")
  if (!is.null(to))
    to <- data.table::year(data.table::as.IDate(to, "%Y-%m-%d"))

  x <- get_code(type = correspond,
                from = data.table::year(data.table::as.IDate(from, "%Y-%m-%d")),
                to = to)

  z <- get_code(type = type,
                from = data.table::year(data.table::as.IDate(from, "%Y-%m-%d")),
                to = to)

  cols <- c("sourceCode",
            "sourceName",
            "targetCode",
            "targetName",
            "validFrom",
            "validTo")

  cx <- switch(type,
               kommune = 4,
               fylke = 2)

  x[, sourceCode := substr(code,1,cx)]
  x[z, on = c(sourceCode = "code"), sourceName := i.name]

  colx <- c("code", "name")
  coln <- c("targetCode", "targetName")
  data.table::setnames(x, colx, coln, skip_absent = TRUE)
  colz <- intersect(cols, names(x))
  data.table::setcolorder(x, colz)
}
