source("scripts/product-library.R")
library<-activate_product_library()
if(!dir.exists(file.path(library,"OpenTrialDesign")))stop("Install the product in the selected library first.")
suppressPackageStartupMessages(library(OpenTrialDesign,lib.loc=library))
args<-commandArgs(trailingOnly=TRUE)
if(identical(args,"--diagnostics")) {
  print(.libPaths());print(runtime_diagnostics())
} else if(identical(args,"--check")) {
  stopifnot(sample_size(trial_spec())$data$n_per_arm==64)
  cat("Product library and engine smoke check passed.\n")
} else if(identical(args,"--test")) {
  testthat::test_package("OpenTrialDesign")
} else if(!length(args)) {
  run_app(host="127.0.0.1",port=as.integer(Sys.getenv("OTD_PORT","3838")),launch.browser=interactive())
} else stop("Use no arguments, --diagnostics, --check or --test")
