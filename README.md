# norgeo <img src='man/figures/logo.png' align="right" width="120" height="139" />

<!-- badges: start -->

[![R build
status](https://github.com/helseprofil/norgeo/workflows/R-CMD-check/badge.svg)](https://github.com/helseprofil/norgeo/actions)
[![Codecov test
coverage](https://img.shields.io/codecov/c/github/helseprofil/norgeo?logo=codecov)](https://app.codecov.io/gh/helseprofil/norgeo?branch=main)
[![](https://www.r-pkg.org/badges/version/norgeo?color=green)](https://cran.r-project.org/package=norgeo)
[![](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Download](https://cranlogs.r-pkg.org/badges/grand-total/norgeo)](https://cranlogs.r-pkg.org/badges/grand-total/norgeo)
[![GitHub R package version
(branch)](https://img.shields.io/github/r-package/v/helseprofil/norgeo/master)](https://github.com/helseprofil/norgeo)
<!-- badges: start -->

## Intro

Regional granularity levels in Norway which are depicted by different
codes, have undergone several changes over the years. Identifying when
codes have changed and how many changes have taken place over several
years can be troublesome. This package will help to identify these
changes and track when the changes have taken place. The codes are based
on those available from [SSB](https://www.ssb.no).

## Installation

`norgeo` package can be installed directly from CRAN or via **GitHub**
page of [Helseprofil](https://github.com/helseprofil). To install from
CRAN:

``` r
install.packages("norgeo")
```

If you want to install the development version then use `pak` package to
access to the **GitHub**. Running the codes below will install
development version of `norgeo`.

``` r
if(!require(pak)) install.packages("pak")
pak::pkg_install("helseprofil/norgeo")
```

## Usage

The data is downloaded via API form SSB
[Klass](https://data.ssb.no/api/klass/v1/api-guide.html "ssb"). To learn
how to use the different functions in **norgeo**, please read the
tutorial under [Get
Started](https://helseprofil.github.io/norgeo/articles/use-api.html)

## Output

Among the output produced by the function `track_change()` is as
follows:

<figure>
<img src="man/figures/kommune_merge.png" alt="output-result" />
<figcaption aria-hidden="true">output-result</figcaption>
</figure>

The data elucidate the complexity of all the codes change. For Larvik
for instance, the municipality has grown in 2020 with the inclusion of
Lardal. Therefore the code for Larvik has changed twice. How about
Holmestrand? When there are more than 350 municipalities with different
code changes, then tracking these can be a nightmare. The same with
enumeration units ie. *grunnkretser* with 14000 units!
