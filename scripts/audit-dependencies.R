packages <- c("stats", "survival", "simsurv", "ggplot2", "gsDesign", "rpact",
              "shiny", "rmarkdown", "testthat", "roxygen2", "renv")
functions <- list(stats = c("power.t.test", "power.prop.test"),
  survival = c("Surv", "coxph", "survdiff"), simsurv = "simsurv",
  gsDesign = c("gsDesign", "nSurv", "gsProbability", "gsCP", "sfLDPocock", "sfLDOF"),
  rpact = c("getDesignGroupSequential", "getDesignInverseNormal", "getData", "getSampleSizeMeans",
    "getSampleSizeRates", "getSampleSizeSurvival", "getSimulationMeans"))
for (p in packages) {
  cat("\nPACKAGE", p, "\n")
  if (!requireNamespace(p, quietly = TRUE)) { cat("UNAVAILABLE\n"); next }
  d <- utils::packageDescription(p)
  print(d[c("Version", "License", "Depends", "Imports")])
  for (f in functions[[p]]) {
    cat("EXPORT", f, "\n")
    print(formals(getExportedValue(p, f)))
  }
}
print(sessionInfo())
