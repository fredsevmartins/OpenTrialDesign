project_arguments <- function(workflow) {
  fixed <- c("endpoint", "effect", "sd", "p_control", "alpha", "power", "alternative")
  switch(workflow,
    example = c("id", "nsim", "seed"),
    fixed_sample_size = fixed,
    fixed_power = c(fixed, "n_per_arm"),
    fixed_simulation = c(fixed, "n_per_arm", "nsim", "seed", "null"),
    sequential_design = names(formals(sequential_design)),
    sequential_means = names(formals(sequential_sample_size)),
    adaptive_simulation = names(formals(adaptive_simulation)),
    survival_design = names(formals(survival_design)),
    survival_simulation = names(formals(simulate_survival)),
    fail("unknown project workflow"))
}
project_workflows <- c("example", "fixed_sample_size", "fixed_power", "fixed_simulation",
  "sequential_design", "sequential_means", "adaptive_simulation",
  "survival_design", "survival_simulation")
project_defaults <- function(workflow) {
  defaults <- function(fn) {
    values <- formals(fn)
    # Only trusted package formals are evaluated; imported data are never code.
    values <- values[!vapply(values, function(x) identical(x, quote(expr=)), logical(1))]
    lapply(values, function(x) {
      value <- eval(x, envir = environment(fn))
      if (is.character(value) && length(value)>1) value[1] else value
    })
  }
  fixed <- defaults(trial_spec)
  switch(workflow, example = list(id="TD-001",nsim=1000,seed=2026),
    fixed_sample_size = fixed,
    fixed_power = c(fixed, list(n_per_arm=64)),
    fixed_simulation = c(fixed, list(n_per_arm=64), defaults(simulate_trial)),
    sequential_design = defaults(sequential_design),
    sequential_means = defaults(sequential_sample_size),
    adaptive_simulation = defaults(adaptive_simulation),
    survival_design = defaults(survival_design),
    survival_simulation = c(list(n_per_arm=64), defaults(simulate_survival)))
}
#' Create a portable, non-executable trial project
#'
#' Projects are versioned JSON-compatible specifications. Construction validates
#' schema, argument names and primitive value types. Scientific domain checks
#' run in the corresponding engine when execute_project is called. Imports
#' never evaluate R expressions or deserialize executable R objects.
#' @param workflow One of the workflows shown in the examples.
#' @param parameters Named list of arguments for the selected workflow.
#' @param title Human-readable project title.
#' @return An otd_project.
#' @export
#' @examples
#' p <- trial_project("fixed_sample_size", list(effect = 0.5), "Normal trial")
#' execute_project(p)
trial_project <- function(workflow = "fixed_sample_size", parameters = list(),
                          title = "Untitled trial") {
  if (!is.character(workflow) || length(workflow) != 1 || is.na(workflow) ||
      !workflow %in% project_workflows) fail("unknown project workflow")
  if (!is.character(title) || length(title) != 1 || is.na(title) ||
      !nzchar(trimws(title)) || nchar(title) > 200) fail("title must contain 1 to 200 characters")
  if (!is.list(parameters) || (length(parameters) &&
      (is.null(names(parameters)) || anyNA(names(parameters)) ||
       any(!nzchar(names(parameters))) || anyDuplicated(names(parameters)))))
    fail("parameters must be a uniquely named list")
  unknown <- setdiff(names(parameters), project_arguments(workflow))
  if (length(unknown)) fail(paste("unknown project parameters:", paste(unknown, collapse = ", ")))
  chars <- c("id", "endpoint", "alternative", "engine", "spending", "futility")
  logicals <- "null"
  for (key in names(parameters)) {
    value <- parameters[[key]]
    if (is.null(value) && key == "events") next
    if (key %in% chars) {
      if (!is.character(value) || length(value) != 1 || is.na(value)) fail(paste(key, "must be one string"))
    } else if (key %in% logicals) {
      if (!is.logical(value) || length(value) != 1 || is.na(value)) fail(paste(key, "must be logical"))
    } else {
      if (!is.numeric(value) || !length(value) || any(!is.finite(value)) ||
          (key != "information" && length(value) != 1)) fail(paste(key, "must be finite numeric data"))
    }
  }
  frozen <- project_defaults(workflow)
  for (key in names(parameters)) frozen[key] <- parameters[key]
  structure(list(format = "OpenTrialDesign-project", schema_version = 1L,
    created_with = as.character(utils::packageVersion("OpenTrialDesign")),
    title = title, workflow = workflow, parameters = frozen), class = "otd_project")
}
check_project <- function(project) {
  if (!inherits(project, "otd_project")) fail("project must be created with trial_project or read_project")
  rebuilt <- trial_project(project$workflow, project$parameters, project$title)
  rebuilt$created_with <- project$created_with
  if (!is.character(project$created_with) || length(project$created_with)!=1 ||
      is.na(project$created_with) || !nzchar(project$created_with)) fail("invalid project software version")
  if (!isTRUE(all.equal(project, rebuilt, check.attributes = TRUE))) fail("invalid or modified project schema")
  invisible(project)
}
#' Execute a saved project using the shared statistical engine
#' @param project An otd_project.
#' @return An otd_result with the complete project snapshot attached.
#' @export
execute_project <- function(project) {
  check_project(project)
  args <- project$parameters; workflow <- project$workflow
  if (startsWith(workflow, "fixed_")) {
    keys <- intersect(names(args), project_arguments("fixed_sample_size"))
    spec <- do.call(trial_spec, args[keys])
    rest <- args[setdiff(names(args), keys)]
    x <- switch(workflow, fixed_sample_size = sample_size(spec),
      fixed_power = do.call(trial_power, c(list(spec = spec), rest)),
      fixed_simulation = do.call(simulate_trial, c(list(spec = spec), rest)))
  } else {
    fn <- switch(workflow, example = run_example, sequential_design = sequential_design,
      sequential_means = sequential_sample_size, adaptive_simulation = adaptive_simulation,
      survival_design = survival_design, survival_simulation = simulate_survival)
    x <- do.call(fn, args)
  }
  x$project <- project
  x
}
#' Save a portable JSON project
#' @param project An otd_project.
#' @param file Destination JSON path.
#' @return The destination path invisibly.
#' @export
write_project <- function(project, file) {
  check_project(project)
  jsonlite::write_json(unclass(project), file, auto_unbox = TRUE, pretty = TRUE,
    digits = 17, null = "null")
  invisible(file)
}
#' Import a strictly versioned, non-executable JSON project
#' @param file JSON project path (maximum 1 MiB).
#' @return An otd_project. Invalid, unsupported or unknown fields raise errors.
#' @export
read_project <- function(file) {
  if (!is.character(file) || length(file) != 1 || !file.exists(file) ||
      is.na(file.info(file)$size) || file.info(file)$size > 1024^2)
    fail("project must be an existing JSON file no larger than 1 MiB")
  x <- tryCatch(jsonlite::fromJSON(file, simplifyVector = TRUE),
    error = function(e) fail("invalid JSON project"))
  fields <- c("format", "schema_version", "created_with", "title", "workflow", "parameters")
  if (!is.list(x) || !setequal(names(x), fields) || anyDuplicated(names(x)) ||
      !identical(x$format, "OpenTrialDesign-project") ||
      !identical(x$schema_version, 1L)) fail("unsupported project schema")
  project <- trial_project(x$workflow, x$parameters, x$title)
  project$created_with <- x$created_with
  check_project(project)
  project
}
#' Flatten numeric/tabular results for spreadsheet export
#' @param x An otd_result.
#' @return A data frame. Nested native engine objects are excluded.
#' @export
result_table <- function(x) {
  if (!inherits(x, "otd_result")) fail("x must be an otd_result")
  if (is.data.frame(x$data$summary)) return(x$data$summary)
  if (is.data.frame(x$data$stage_plan)) return(x$data$stage_plan)
  if (is.data.frame(x$data$boundaries)) return(x$data$boundaries)
  scalars <- x$data[vapply(x$data, function(v) is.atomic(v) && length(v) == 1, logical(1))]
  if (!length(scalars) && !is.null(x$data$native)) return(as.data.frame(x$data$native))
  if (!length(scalars)) fail("result contains no exportable table")
  data.frame(metric = names(scalars), value = vapply(scalars, as.character, character(1)),
    row.names = NULL)
}
#' Export a reproducibility bundle with results and provenance
#' @param x An otd_result, optionally with an attached project.
#' @param file Destination ZIP path.
#' @param include_report Whether to include an HTML report (requires Pandoc).
#' @return Destination path invisibly.
#' @export
export_bundle <- function(x, file, include_report = TRUE) {
  if (!inherits(x, "otd_result")) fail("x must be an otd_result")
  if (!is.logical(include_report) || length(include_report) != 1 || is.na(include_report)) fail("include_report must be logical")
  need("zip")
  scratch <- tempfile("otd-bundle-"); dir.create(scratch)
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  utils::write.csv(result_table(x), file.path(scratch, "results.csv"), row.names = FALSE)
  saveRDS(x, file.path(scratch, "result.rds"))
  writeLines(capture.output(print(x)), file.path(scratch, "summary.txt"))
  writeLines(capture.output(dput(x$specification)), file.path(scratch, "assumptions.txt"))
  writeLines(capture.output(dput(x$provenance)), file.path(scratch, "provenance.txt"))
  writeLines(capture.output(utils::sessionInfo()), file.path(scratch, "session.txt"))
  if (!is.null(x$project)) {
    write_project(x$project, file.path(scratch, "project.json"))
    utils::write.csv(review_project(x$project),file.path(scratch,"scientific-review.csv"),row.names=FALSE)
  }
  if (identical(x$kind,"scenario sensitivity analysis")) {
    dir.create(file.path(scratch,"scenarios"))
    for (i in seq_along(x$data$projects)) {
      id<-sprintf("S%03d",i)
      write_project(x$data$projects[[i]],file.path(scratch,"scenarios",paste0(id,".json")))
    }
    utils::write.csv(data.frame(file=sprintf("S%03d.json",seq_along(x$data$projects)),scenario=names(x$data$projects)),
      file.path(scratch,"scenarios","index.csv"),row.names=FALSE)
    utils::write.csv(x$data$failures,file.path(scratch,"failures.csv"),row.names=FALSE)
  }
  if (include_report) render_report(x, file.path(scratch, "report.html"))
  paths <- list.files(scratch, full.names = TRUE, recursive = TRUE)
  utils::write.csv(data.frame(file = substring(paths,nchar(scratch)+2), md5 = unname(tools::md5sum(paths))),
    file.path(scratch, "manifest.csv"), row.names = FALSE)
  writeLines(c("OpenTrialDesign reproducibility bundle", "CSV values are unrounded computational outputs.",
    "project.json (when present) is the non-executable replay configuration.",
    "result.rds is an R object for trusted local archival; never import untrusted RDS files.",
    "manifest.csv records MD5 integrity checks, not cryptographic authenticity."),
    file.path(scratch, "README.txt"))
  target <- file.path(normalizePath(dirname(file), mustWork = TRUE), basename(file))
  zip::zipr(target, files = list.files(scratch), root = scratch)
  invisible(target)
}
