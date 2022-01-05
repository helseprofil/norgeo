# norgeo <img src='man/figures/logo.png' align="right" height="139" />

[![R build
status](https://github.com/helseprofil/norgeo/workflows/R-CMD-check/badge.svg)](https://github.com/helseprofil/norgeo/actions)
[![](https://www.r-pkg.org/badges/version/norgeo?color=green)](https://cran.r-project.org/package=norgeo)
[![CRAN
checks](https://cranchecks.info/badges/summary/norgeo)](https://cran.r-project.org/web/checks/check_results_norgeo.html)
[![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![](https://img.shields.io/badge/devel%20version-2.0.0-blue.svg)](https://github.com/helseprofil/norgeo)

<!-- <\!-- badges: start -\-> -->
<!-- [![R-CMD-check](https://github.com/helseprofil/norgeo/workflows/R-CMD-check/badge.svg)](https://github.com/helseprofil/norgeo/actions) -->
<!-- <\!-- badges: end -\-> -->

Regional granularity levels in Norway which are depicted by different
codes, have undergone several changes over the years. Identifying when
codes have changed and how many changes have taken place can be
troublesome. This package will help to identify these changes and when
the changes have taken place. One of the limitation of this package is
that it is heavily depending on the codes available from SSB which can
be accessed from their
[website](https://www.ssb.no/befolkning/artikler-og-publikasjoner/regionale-endringer-2020).

## Installation

`norgeo` package can be installed directly from **GitHub** page of
[Helseprofil](https://github.com/helseprofil). You can run the code
below for installation. It will use `remotes` package to access to the
**GitHub**. If you haven’t installed it before, the package will be
installed automatically prior to installing `norgeo`.

``` r
if(!require(remotes)) install.packages("remotes")
remotes::install_github("helseprofil/norgeo")
```

If you want to use the development version then use:

``` r
remotes::install_github("helseprofil/norgeo@dev")
```

## Usage

The data is downloaded via API form SSB
[website](https://data.ssb.no/api/klass/v1/api-guide.html "ssb"). To
learn how to use the different functions in **norgeo**, please read the
tutorial under [Get
Started](https://helseprofil.github.io/norgeo/articles/use-api.html)

## Output

Among the output produced by the function `get_change()` is as follows:

![output-result](man/figures/kommune_merge.png)

The data elucidate the complexity of all the codes change. For Larvik
for instance, the municipality has grown in 2020 with the inclusion of
Lardal. Therefore the code for Larvik has changed twice. How about
Holmestrand? When there are more than 350 municipality with different
changes, then tracking these can be a nightmare. The same with
enumeration units ie. *grunnkrets* with 14000 units!
