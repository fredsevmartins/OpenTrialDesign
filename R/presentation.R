#' Print a trial result with method provenance
#' @param x An otd_result.
#' @param ... Unused.
#' @return x invisibly.
#' @export
print.otd_result <- function(x, ...) {
  cat(x$kind, "\nEngine:", paste(x$provenance$engine, collapse = ", "),
      "\nMethod:", x$provenance$method, "\n")
  visible <- x$data[setdiff(names(x$data), c("native", "design"))]
  if (length(visible)) print(visible) else if (!is.null(x$data$native)) print(x$data$native)
  cat("Validation:", x$provenance$validation, "\n")
  invisible(x)
}
#' Plot boundaries or Monte Carlo operating characteristics
#' @param x An otd_result.
#' @return A ggplot object.
#' @export
plot_design <- function(x) {
  if (!inherits(x, "otd_result")) fail("x must be an otd_result")
  if (x$kind == "group sequential design") {
    d <- x$data$boundaries
    dat <- rbind(data.frame(information = d$information, z = d$efficacy, rule = "efficacy"),
                 data.frame(information = d$information, z = d$futility, rule = "futility"))
    dat <- dat[is.finite(dat$z), ]
    return(ggplot2::ggplot(dat, ggplot2::aes(x = .data$information, y = .data$z, colour = .data$rule)) +
      ggplot2::geom_line() + ggplot2::geom_point() + ggplot2::theme_minimal() +
      ggplot2::labs(x = "Information fraction", y = "Canonical Z boundary", colour = "Stopping rule"))
  }
  dat <- if (!is.null(x$data$summary)) x$data$summary else if (!is.null(x$data$estimate))
    data.frame(scenario = x$provenance$method, estimate = x$data$estimate,
      lower = x$data$lower, upper = x$data$upper) else NULL
  if (is.null(dat)) fail("plot_design supports sequential designs and Monte Carlo results")
  ggplot2::ggplot(dat, ggplot2::aes(x = .data$scenario, y = .data$estimate,
    ymin = .data$lower, ymax = .data$upper)) + ggplot2::geom_pointrange() +
    ggplot2::coord_cartesian(ylim = c(0, 1)) + ggplot2::theme_minimal() +
    ggplot2::labs(x = NULL, y = "Rejection probability (exact 95% Monte Carlo interval)")
}
#' Compare fixed sample planning scenarios
#' @param specs Named list of trial_spec objects.
#' @return Data frame with assumptions and analytical sample sizes and powers.
#' @export
compare_scenarios <- function(specs) {
  if (!is.list(specs) || length(specs) == 0) fail("specs must be a nonempty list")
  labels <- names(specs)
  if (is.null(labels)) labels <- as.character(seq_along(specs))
  do.call(rbind, lapply(seq_along(specs), function(i) {
    s <- specs[[i]]; x <- sample_size(s)
    data.frame(scenario = labels[i], endpoint = s$endpoint, effect = s$effect,
      alpha = s$alpha, alternative = s$alternative, target_power = s$power,
      n_per_arm = x$data$n_per_arm, achieved_power = x$data$achieved_power)
  }))
}
#' Inspect scientific provenance and simulation diagnostics
#' @param x An otd_result.
#' @return List of provenance and applicable diagnostic quantities.
#' @export
diagnose_design <- function(x) {
  if (!inherits(x, "otd_result")) fail("x must be an otd_result")
  list(kind = x$kind, provenance = x$provenance, specification = x$specification,
    monte_carlo = x$data[intersect(names(x$data),
      c("nsim", "mcse", "lower", "upper", "target_attainment", "summary"))])
}
#' Render a methodological report
#' @param x An otd_result.
#' @param file Destination .html or .pdf file.
#' @param format Either "html" or "pdf". PDF requires an installed LaTeX engine.
#' @return Absolute output path invisibly.
#' @export
render_report <- function(x, file, format = c("html", "pdf")) {
  if (!inherits(x, "otd_result")) fail("x must be an otd_result")
  format <- match.arg(format); need("rmarkdown")
  if (!rmarkdown::pandoc_available()) fail("Pandoc is required", "otd_dependency_error")
  if (format == "pdf" && !any(nzchar(Sys.which(c("pdflatex", "xelatex", "lualatex")))))
    fail("PDF requires a LaTeX engine", "otd_dependency_error")
  destination <- normalizePath(dirname(file), mustWork = TRUE)
  template <- system.file("report.Rmd", package = "OpenTrialDesign")
  if (!nzchar(template)) fail("report template unavailable: install the package")
  scratch <- tempfile("otd-report-")
  dir.create(scratch)
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  input <- file.path(scratch, "report.Rmd")
  if (!file.copy(template, input)) fail("unable to copy report template")
  path <- rmarkdown::render(input, output_format = paste0(format, "_document"),
    output_file = paste0("report.", format), output_dir = scratch,
    params = list(result = x), envir = new.env(parent = baseenv()), quiet = TRUE)
  requested <- file.path(destination, basename(file))
  if (!file.copy(path, requested, overwrite = TRUE)) fail("unable to write report destination")
  invisible(normalizePath(requested, mustWork = TRUE))
}
#' Launch the optional shared-engine Shiny application
#' @return The result of shiny::runApp.
#' @export
run_app <- function() {
  need("shiny")
  shiny::runApp(system.file("shiny", package = "OpenTrialDesign"))
}
# Declare ggplot's tidy-evaluation pronoun without importing the UI.
utils::globalVariables(".data")
