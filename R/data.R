#' @title Grunnkrets Change Before 2002
#' @description Grunnkrets codes change before 2002 are not available via API.
#' This is a dataset received directly from SSB.
#' @format A data of `data.table` class consisting 3 variables:
#' \describe{
#'   \item{oldCode}{Code before change}
#'   \item{newCode}{Code after change}
#'   \item{changeOccurred}{The year when the change happened}
#' }
#' @source \url{https://www.ssb.no/klass/klassifikasjoner/1/endringer}
"GrunnkretsBefore2002"
