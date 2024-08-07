% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get-correspond.R
\name{get_correspond}
\alias{get_correspond}
\title{Get geo corresponds}
\usage{
get_correspond(
  type = c("fylke", "okonomisk", "kommune", "bydel", "levekaar"),
  correspond = c("fylke", "kommune", "bydel", "grunnkrets"),
  from = NULL,
  to = NULL,
  dt = TRUE,
  names = TRUE
)
}
\arguments{
\item{type}{Higher granularity from specified correspond arg.}

\item{correspond}{Lower granularity from the specified type arg.}

\item{from}{Specify the starting year for range period. Current year is the
default.}

\item{to}{Specify the year to end the range period. Current year is used when
not specified.}

\item{dt}{Output as data.table}

\item{names}{Include names. Default is TRUE}
}
\value{
A dataset of class \code{data.table} representing the lower geographical
level codes and their corresponding higher geographical levels. For example
for codes on enumeration areas and their corresponding codes for
municipalities or town.
}
\description{
This function will get the corresponding geo code of specific granularity via
API from SSB whenever available.
}
\examples{
df <- get_correspond("kommune", "grunnkrets", 2019)

}
