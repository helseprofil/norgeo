
# norgeo <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/helseprofil/norgeo/workflows/R-CMD-check/badge.svg)](https://github.com/helseprofil/norgeo/actions)
<!-- badges: end -->

# norgeo

Regional granularity levels in Norway which are depicted by different
codes, have undergone several changes over the years. Identifying when
codes have changed and how many changes have taken place can be
troublesome. This package will help to identify these changes and when
the changes have taken place. One of the limitation of this package is
that it is heavily depending on the codes available from SSB which can
be accessed from their
[website](https://www.ssb.no/befolkning/artikler-og-publikasjoner/regionale-endringer-2020).
To use other data than those from SSB, it requires that the data
structure mimic those from SSB.

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
for instance, the munucipality has grown in 2020 with the inclusion of
Lardal. Therefore the code for Larvik has changed twice. How about
Holmestrand? When there are more than 350 manucipalities with different
changes, then tracking these can be a nightmare. The same with
enumeration units ie. *grunnkrets* with 14000 units!
