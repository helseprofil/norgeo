#' Cast geo granularity from API
#'
#' Add geo granularity levels to all sides
#'
#' @param year Which year the codes are valid from. If NULL then current year
#'   will be selected.
#'
#' @import data.table
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
    COR[[i]] <- norgeo::find_correspond(COR[[i]][1], COR[[i]][2], from = year)

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
  dt[
    level == "bydel", kommune := gsub("\\d{2}$", "", code)
  ][
    level == "bydel", fylke := gsub("\\d{4}$", "", code)
  ][
    level == "bydel", bydel := code
  ]

  dt[
    level == "kommune", fylke := gsub("\\d{2}$", "", code)
  ][
    level == "kommune", kommune := code
  ]

  ## Only run this after adding lower granularity
  ## else it will overwrite kommune and bydel
  dt[level == "grunnkrets", grunnkrets := code]
  dt[level == "fylke", fylke := code]

  ## dt <- recode_missing_gr(dt)
  dt <- find_missing_kom(dt, year = year)
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
#' @export
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
  message("Data for ", correspond, " to ", type, " is from ", stat$from, " with ", stat$rows, " rows")
  return(dt)
}

## Grunnkrets that only exist in previous year need to be added if changes
## only happpened previous years from find_correspond. eg. 15390107
merge_geo <- function(dt, cor, geo, year){
  # dt - Data from get_code
  # cor - Data from get_correspond
  # geo - What geo granularity is the data for
  # year - Year as in validTo column
  level <- targetName <- sourceCode <- NULL
  if (geo == "fylke"){
    DT <- data.table::merge.data.table(dt, cor, by.x = "kommune", by.y = "code", all = TRUE)
  } else {
    DT <- data.table::merge.data.table(dt, cor, by = "code", all = TRUE)
  }

  grn <- DT[is.na(level), code]
  DT[code %chin% grn, c("level", "validTo", "name") := list("grunnkrets", year, targetName)]
  DT[, (geo) := sourceCode]
  DT[, c("sourceCode", "sourceName", "targetName") := NULL]
}


## Helper ------------------------------------------------------
recode_missing_gr <- function(dt){
  dd <- dt[is.na(code),]
  dd <- is_missing(dd, "kommune")
  dd <- is_missing(dd, "fylke")
  dd[is.na(code), code := "99999999"]
  dt <- data.table::rbindlist(list(dt, dd), use.names = TRUE)
}

## other than grunnkrets
is_missing <- function(dt, col){
  for (i in seq_len(nrow(dt))){
    dd <- dt[i]
    if (isFALSE(is.na(dt[[col]]))){
      col9 <- missing_number(col = col)
      val <- paste0(dt[[col]], col9)
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


find_missing_gr <- function(dt = NULL, code = NULL, year = NULL){
  ## When enumeration number (grunnkrets) doesn't have missing
  ## then need to add it manually because some raw datasets have this code
  ## and it's needed to be able to merged for summing up for country total
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


find_missing_kom <- function(dt = NULL, year = NULL){
  kom <- unique(dt$kommune)
  komm <- kom[!is.na(kom)]

  DT <- vector(mode = "list", length = length(komm))
  for (i in seq_len(length(komm))){
    naKom <- paste0(komm[i], "9999")
    dk <- dt[kommune == komm[i]]
    kk <- komm[i]
    dd <- recode_missing_kom(dk, code = naKom, komm = kk, year = year)
    DT[[i]] <- dd
}
  dkom <- data.table::rbindlist(DT)
  out <- data.table::rbindlist(list(dt, dkom), use.names = TRUE)
}

recode_missing_kom <- function(dd = NULL, code = NULL, komm = NULL, year = NULL){

  if (isFALSE(is.element(code, dd$code))){
    gk <- list(
      code = code,
      name = "Uoppgitt",
      validTo = year,
      level = "grunnkrets",
      grunnkrets = code,
      kommune = komm,
      fylke = gsub("\\d{2}$", "", komm),
      bydel = ""
    )
  }
}
