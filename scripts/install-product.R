# Run from the repository root with a standard R >= 4.2 installation.
if (!requireNamespace("renv", quietly=TRUE))
  install.packages("renv", repos="https://cloud.r-project.org")
renv::restore(lockfile="renv.lock", prompt=FALSE)
status <- system2(file.path(R.home("bin"),"R"), c("CMD","build","."))
if (status != 0) stop("Package build failed")
status <- system2(file.path(R.home("bin"),"R"), c("CMD","INSTALL","OpenTrialDesign_0.2.0.tar.gz"))
if (status != 0) stop("Package installation failed")
cat("Start the product with OpenTrialDesign::run_app()\n")
