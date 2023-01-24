
#norsk <- grepl("Norwegian", Sys.getlocale("LC_TIME"), ignore.case = TRUE)

.onLoad <- function(libname, pkgname){

  ## Encoding after R ver 4.2 and above to UTF-8
  if (Sys.info()["sysname"] == "Windows") {
    if (rvers()) {
      Sys.setlocale("LC_CTYPE", "nb_NO.UTF-8")
      message('"LC_CTYPE" is set to nb_NO.UTF-8')
      message('To change it run Sys.setlocale("LC_CTYPE", ctype) where `ctype` is your preferred type')
    }
  }
}

.onAttach <- function(libname, pkgname){
  packageStartupMessage(paste("norgeo version",
                              utils::packageDescription("norgeo")[["Version"]]))
}


rvers <- function(){
  rlokal <- paste(version[c("major", "minor")], collapse = ".")
  numeric_version(rlokal) > numeric_version("4.1.0")
}
