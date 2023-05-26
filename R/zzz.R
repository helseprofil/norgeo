.onAttach <- function(libname, pkgname){
  packageStartupMessage(paste("norgeo version",
                              utils::packageDescription("norgeo")[["Version"]]))
}


# Columnames to be deleted if options for names = FALSE
granularityNames <- c("oldName", "newName")
