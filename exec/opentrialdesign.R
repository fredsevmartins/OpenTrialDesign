#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(OpenTrialDesign))
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) || "--help" %in% args) {
  cat("OpenTrialDesign batch runner\n",
      "  Rscript opentrialdesign.R --project design.json --output results.zip\n",
      "  Rscript opentrialdesign.R --diagnostics\n", sep="")
  quit(status=0)
}
tryCatch({
  if (identical(args,"--diagnostics")) {print(runtime_diagnostics());quit(status=0)}
  if (length(args)!=4 || !identical(args[c(1,3)],c("--project","--output")))
    stop("Use --project design.json --output results.zip")
  project <- read_project(args[2])
  result <- execute_project(project)
  export_bundle(result,args[4],include_report=FALSE)
  print(result)
  cat("Bundle written to ",normalizePath(args[4]),"\n",sep="")
},error=function(e){cat("OpenTrialDesign: ",conditionMessage(e),"\n",sep="",file=stderr());quit(status=1)})
