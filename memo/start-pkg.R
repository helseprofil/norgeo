## Maintaining
devtools::load_all()
devtools::test()
devtools::document()
devtools::check()

## Building website
pkgdown::build_site()
pkgdown::build_news(preview = TRUE)

# Use CI
usethis::use_git_remote("origin", url = "https://github.com/helseprofil/norgeo.git", overwrite = TRUE)
usethis::use_github_action_check_standard()
usethis::use_git_remote("origin", url = "git@work:helseprofil/norgeo.git", overwrite = TRUE)

