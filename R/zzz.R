.onAttach <- function(libname, pkgname){
  packageStartupMessage(paste("norgeo version",
                              utils::packageDescription("norgeo")[["Version"]]))
}
