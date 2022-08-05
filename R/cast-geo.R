#' @title Cast geo granularity from API
#'
#' @description Add geo granularity levels to all sides
#'
#' @param year Which year the codes are valid from. If NULL then current year
#'   will be selected.
#'
#' @import data.table
#' @return A dataset of class `data.table` representing the spreading of
#'   different geographical levels from lower to higher levels ie. from
#'   enumeration area codes to county codes, for the selected year.
#' @examples
#' \dontrun{
#'  DT <- cast_geo(2020)
#' }
#' @export

cast_geo <- function(year = NULL) {
  cat("Start casting geo codes from API ..")
  level <- sourceCode <- kommune <- fylke <- grunnkrets <- bydel <- NULL

  if (is.null(year)) {
    year <- as.integer(format(Sys.Date(), "%Y"))
  }

  geos <- c("fylke", "kommune", "bydel", "grunnkrets")

  DT <- vector(mode = "list", length = 4)
  ## Get geo codes
  for (i in seq_along(geos)) {
    DT[[geos[i]]] <- norgeo::get_code(geos[i], from = year)
    DT[[geos[i]]][, level := geos[i]]
    cat("..")
  }

  dt <- data.table::rbindlist(DT)


  ## SSB has correspond data only for
  ## - bydel-grunnkrets
  ## - kommune-grunnkrets
  ## - fylke-kommue

  COR <- list(
    gr_bydel = c("bydel", "grunnkrets"),
    gr_kom = c("kommune", "grunnkrets"),
    kom_fylke = c("fylke", "kommune")
  )

  cat("..\n")

  for (i in seq_along(COR)) {
    COR[[i]] <- find_correspond(COR[[i]][1], COR[[i]][2], from = year)

    keepCols <- c("sourceCode", "sourceName", "targetCode", "targetName")
    delCol <- base::setdiff(names(COR[[i]]), keepCols)
    COR[[i]][, (delCol) := NULL]
    data.table::setnames(COR[[i]], "targetCode", "code")
  }

  dt <- merge_geo(dt, COR$gr_bydel, "bydel", year)
  dt <- merge_geo(dt, COR$gr_kom, "kommune", year)
  dt <- merge_geo(dt, COR$kom_fylke, "fylke", year)

  ## Merge geo code
  ## Add higher granularity that aren't available via correspond API
  dt[level == "bydel", kommune := gsub("\\d{2}$", "", code)][
    level == "bydel", fylke := gsub("\\d{4}$", "", code)][
      level == "bydel", bydel := code]

  dt[level == "kommune", fylke := gsub("\\d{2}$", "", code)][
    level == "kommune", kommune := code]

  ## Only run this after adding lower granularity
  ## else it will overwrite kommune and bydel
  dt[level == "grunnkrets", grunnkrets := code]
  dt[level == "fylke", fylke := code]

  kombydel99 <- dt[bydel %like% "99$", list(kommune, bydel)]
  kom_with_bydel99 <- kombydel99$kommune
  bydel99 <- kombydel99$bydel

  dt <- recode_missing_gr(dt)
  dt <- find_missing_kom_bydel(dt, bydel99 = kom_with_bydel99, year = year)

  ## Use only after coding for missing kommune and fylke because
  ## it looks for is.na(bydel) in existing rows while find_missing_kom_bydel add new rows
  dt <- find_missing_bydel(dt, bydel99)
  dt <- find_missing_gr(dt, "99999999", year = year)

  data.table::setcolorder(dt,
                          c("code", "name", "validTo", "level",
                            "grunnkrets", "kommune", "fylke", "bydel"))
}

#' @title Find existing correspond
#' @description Unlike [get_correspond()] functions, this function will find existing
#'   correspond if the specified year has no correspond codes.
#'   Correspond codes can be empty if nothing has changed in
#'   that specific year and need to get from previous year or even
#'   year before before previous year etc..etc.. This function is needed
#'   when running [cast_geo()].
#' @inheritParams get_correspond
#' @return A dataset of class `data.table` representing the lower geographical
#'   level codes and their corresponding higher geographical levels. For example
#'   for codes on enumeration areas and their corresponding codes for
#'   municipalities or town.
#' @keywords internal
find_correspond <- function(type, correspond, from) {
  ## type: Higher granularity eg. fylker
  ## correspond: Lower granularity eg. kommuner
  stat <- list(rows = 0, from = from)
  nei <- 0
  while (nei < 1) {
    dt <- norgeo::get_correspond(type, correspond, from)
    nei <- nrow(dt)
    stat$rows <- nei
    stat$from <- from
    from <- from - 1
  }
  message("Data for ", correspond, " to ", type, " in ", stat$from, " have ", stat$rows, " rows")
  return(dt)
}


## Helper ------------------------------------------------------

## Grunnkrets that only exist in previous year need to be added if changes
## only happpened previous years from find_correspond. eg. 15390107
merge_geo <- function(dt, cor, geo, year){
  # dt - Data from get_code
  # cor - Data from get_correspond
  # geo - What geo granularity is the data for
  # year - Year as in validTo column
  level <- targetName <- sourceCode <- NULL

  if (geo == "fylke"){
    # Fylke uses kommune as id for merging
    DT <- data.table::merge.data.table(dt, cor, by.x = "kommune", by.y = "code", all = TRUE)
  } else {
    # kommune and bydel use grunnkrets as id for merging
    DT <- data.table::merge.data.table(dt, cor, by = "code", all = TRUE)
  }

  grn <- DT[is.na(level), code]
  DT[code %chin% grn, c("level", "validTo", "name") := list("grunnkrets", year, targetName)]
  DT[, (geo) := sourceCode]
  DT[, c("sourceCode", "sourceName", "targetName") := NULL]
}

## Some years have missing code eg. 10199999 for grunnkrets, but when not available
## then add it manually
recode_missing_gr <- function(dt){
  dd <- dt[is.na(code),] # grunnkrets code
  dd <- is_missing(dd, "bydel")
  dd <- is_missing(dd, "kommune")
  dd <- is_missing(dd, "fylke")
  dd[is.na(code), code := "99999999"]
  dt <- data.table::rbindlist(list(dt, dd), use.names = TRUE)
}

## other than grunnkrets missing code
## than needs to be added manually
is_missing <- function(dt, col){
  for (i in seq_len(nrow(dt))){
    dd <- dt[i]
    if (isFALSE(is.na(dd[[col]]))){
      col9 <- missing_number(col = col)
      val <- paste0(dd[[col]], col9)
      dt[i, code := val]
    }
  }
  return(dt)
}


missing_number <- function(col = NULL){
  data.table::fcase(col == "fylke", "999999",
                    col == "kommune", "9999",
                    col == "bydel", "99")
}


## When enumeration number (grunnkrets) doesn't have missing ie. 99999999
## then need to add it manually because some raw datasets have this code
## and it's needed to be able to merged for summing up for country total
find_missing_gr <- function(dt = NULL, code = NULL, year = NULL){
  if (isFALSE(is.element(code, dt$code))) {
    ## validYr <- dt[level == "grunnkrets", c(validTo)][1]
    gk <- list(
      code = code,
      name = "Uoppgitt",
      validTo = year,
      level = "grunnkrets",
      grunnkrets = code,
      kommune = "9999",
      fylke = "99",
      bydel = "999999"
    )

    dt <- data.table::rbindlist(list(dt, gk), use.name = TRUE)
  }
  return(dt)
}


## Unknown grunnkrets with known kommune ended with 9999
## This should be extracted and added in kommune column
find_missing_kom_bydel <- function(dt = NULL, bydel99 = NULL, year = NULL){
  kommune <- NULL
  kom <- unique(dt$kommune)
  komm <- kom[!is.na(kom)]

  DT <- vector(mode = "list", length = length(komm))
  for (i in seq_len(length(komm))){
    # Uoppgitt in grunnkrets ended with 9999 for kommune
    naKom <- paste0(komm[i], "9999")
    dk <- dt[kommune == komm[i]]
    kk <- komm[i]
    dd <- recode_missing_kom(dk,
                             code = naKom,
                             komm = kk,
                             bydel99 = bydel99,
                             year = year)
    DT[[i]] <- dd
  }
  dkom <- data.table::rbindlist(DT)
  out <- data.table::rbindlist(list(dt, dkom), use.names = TRUE)
}


recode_missing_kom <- function(dd = NULL,
                               code = NULL,
                               komm = NULL,
                               bydel99 = NULL,
                               year = NULL){
  # code - missing code in grunnkrets
  # dd - subset for seleted kommune code
  # komm - kommune code
  if (isFALSE(is.element(code, dd$code))){
    gk <- list(
      code = code,
      name = "Uoppgitt",
      validTo = year,
      level = "grunnkrets",
      grunnkrets = code,
      kommune = komm,
      fylke = gsub("\\d{2}$", "", komm),
      bydel = missing_kom_bydel(komm, bydel99)
    )
  }
}

missing_kom_bydel <- function(komm, bydel99){
  if (isTRUE(is.element(komm, bydel99))){
    code <- paste0(komm, "99")
  } else {
    code <- NA
  }
  invisible(code)
}

## Missing (uoppgitt) bydel ended with xxxx99
## Apply only after recoding missing kommune and fylke
find_missing_bydel <- function(dt, bydel99 = NULL){
  bydel <- NULL

  for (i in seq_len(length(bydel99))){
    naBydel <- paste0(bydel99[i], "99")
    bycode <- bydel99[i]
    dt[code == naBydel & is.na(bydel), bydel := bycode]
  }
  invisible(dt)
}
