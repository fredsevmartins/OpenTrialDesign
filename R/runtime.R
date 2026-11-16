#' Inspect installed capabilities before starting a workflow
#' @return A data frame of engine and rendering capabilities.
#' @export
runtime_diagnostics <- function() {
  packages <- c("stats", "survival", "ggplot2", "gsDesign", "rpact", "simsurv",
                "shiny", "callr", "zip", "rmarkdown")
  rows <- lapply(packages, function(p) {
    available <- requireNamespace(p, quietly = TRUE)
    version <- if (available) as.character(utils::packageVersion(p)) else NA_character_
    minimum <- if (p %in% names(engine_minimum)) engine_minimum[[p]] else NA_character_
    compatible <- available && (is.na(minimum) || package_version(version) >= package_version(minimum))
    data.frame(capability = p, available = available, version = version,
      minimum = minimum, usable = compatible)
  })
  rows[[length(rows)+1]] <- data.frame(capability = "Pandoc", available =
    requireNamespace("rmarkdown", quietly = TRUE) && rmarkdown::pandoc_available(),
    version = NA_character_, minimum = NA_character_, usable =
    requireNamespace("rmarkdown", quietly = TRUE) && rmarkdown::pandoc_available())
  latex <- any(nzchar(Sys.which(c("pdflatex", "xelatex", "lualatex"))))
  rows[[length(rows)+1]] <- data.frame(capability = "LaTeX", available = latex,
    version = NA_character_, minimum = NA_character_, usable = latex)
  do.call(rbind, rows)
}
