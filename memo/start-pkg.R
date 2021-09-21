## Make sure the root is at package
pkgs <- c(
  "usethis", "roxygen2", "devtools", "rmarkdown", "knitr", "pkgdown", "here", "fs",
  "data.table", "readxl", "openxlsx", "DBI", "odbc", "writexl", "RSQLite"
  )
## install.packages(pkgs)

## install.packages("renv")
## renv::init(bare = TRUE)
## renv::install(pkgs)
## renv::snapshot()

## Looping
devtools::load_all()
devtools::document()
roxygen2::roxygenise(clean = TRUE)
devtools::check()
devtools::test()

## Sys.unsetenv("R_PROFILE_USER")
devtools::check()
                                        # Run to build the website
pkgdown::build_site(new_process = FALSE)
pkgdown::build_news(preview = TRUE)

# Use CI
usethis::use_git_remote("origin", url = "https://github.com/helseprofil/norgeo.git", overwrite = TRUE)
usethis::use_github_action_check_standard()
usethis::use_git_remote("origin", url = "git@work:helseprofil/norgeo.git", overwrite = TRUE)
