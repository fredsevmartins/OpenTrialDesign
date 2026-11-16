product_library <- function(create=FALSE) {
  if (!file.exists("DESCRIPTION") || read.dcf("DESCRIPTION")[1,"Package"]!="OpenTrialDesign")
    stop("Run this command from the OpenTrialDesign repository root.")
  path <- Sys.getenv("OTD_R_LIBRARY",unset=file.path(tools::R_user_dir("OpenTrialDesign","cache"),"library",
    read.dcf("DESCRIPTION")[1,"Version"],paste0("R-",getRversion()),R.version$platform))
  if(create)dir.create(path,recursive=TRUE,showWarnings=FALSE)
  if(!dir.exists(path))stop("Product library is missing; run scripts/install-product.R first.")
  path<-normalizePath(path,winslash="/",mustWork=TRUE)
  root<-normalizePath(getwd(),winslash="/",mustWork=TRUE)
  if(startsWith(path,paste0(root,"/")))stop("Choose a product library outside the source checkout.")
  path
}
activate_product_library <- function(create=FALSE) {
  path<-product_library(create)
  .libPaths(c(path,.libPaths()))
  Sys.setenv(R_LIBS=path,R_LIBS_USER=path)
  path
}
