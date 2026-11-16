job_registry <- new.env(parent=emptyenv())
prune_jobs <- function() {
  for (key in ls(job_registry)) {
    if (!job_registry[[key]]$process$is_alive()) rm(list=key,envir=job_registry)
  }
}
#' Start a simulation in an isolated background R process
#'
#' Only the simulation workflows in the portable project schema are accepted.
#' Each worker receives its own seed and project snapshot. Cancelling terminates
#' the worker; a partial Monte Carlo run is never labeled a completed result.
#' @param project An otd_project for a simulation workflow.
#' @return An otd_job handle, local to the current R session.
#' @export
start_simulation <- function(project) {
  check_project(project)
  if (!project$workflow %in% c("fixed_simulation", "adaptive_simulation", "survival_simulation", "example", "means_simulation", "nonph_simulation"))
    fail("background jobs require a simulation or example project")
  start_job(project,function(project)OpenTrialDesign::execute_project(project))
}
start_job <- function(project,execute) {
  need("callr")
  prune_jobs()
  limit <- getOption("OpenTrialDesign.max_jobs",4L)
  integer_count(limit,"maximum active jobs")
  if(length(ls(job_registry))>=limit) fail("Simulation capacity is full; retry after an active job finishes.","otd_capacity_error")
  job <- new.env(parent = emptyenv())
  job$project <- project; job$cancelled <- FALSE; job$collected <- FALSE
  job$created <- Sys.time(); job$finished <- NULL; job$id <- basename(tempfile("otd-job-"))
  job$process <- callr::r_bg(function(project,execute) {
    tryCatch(list(ok = TRUE, result = execute(project)),
      error = function(e) list(ok = FALSE, message = conditionMessage(e), classes = class(e)))
  }, args = list(project = project,execute=execute), libpath = .libPaths(), supervise = TRUE, user_profile = FALSE, system_profile = FALSE)
  class(job) <- "otd_job"
  job_registry[[job$id]] <- job
  job
}
check_job <- function(job) {
  if (!inherits(job, "otd_job") || !is.environment(job)) fail("invalid simulation job")
}
#' Inspect a background simulation without blocking
#' @param job A handle from start_simulation.
#' @return A list with state (running, completed, failed or cancelled), elapsed
#'   seconds and error message when applicable.
#' @export
simulation_status <- function(job) {
  check_job(job)
  if (is.null(job$finished) && !job$process$is_alive()) job$finished <- Sys.time()
  if (!is.null(job$finished) && exists(job$id,envir=job_registry,inherits=FALSE)) rm(list=job$id,envir=job_registry)
  endpoint <- if(is.null(job$finished))Sys.time() else job$finished
  elapsed <- as.numeric(difftime(endpoint, job$created, units = "secs"))
  if (job$cancelled) return(list(state = "cancelled", elapsed_seconds = elapsed))
  if (job$process$is_alive()) return(list(state = "running", elapsed_seconds = elapsed))
  answer <- tryCatch(job$process$get_result(), error = function(e)
    list(ok = FALSE, message = conditionMessage(e)))
  if (!isTRUE(answer$ok)) return(list(state = "failed", elapsed_seconds = elapsed,
    message = answer$message))
  list(state = "completed", elapsed_seconds = elapsed)
}
#' Collect a completed simulation without accepting partial results
#' @param job A simulation job.
#' @return An otd_result; structured errors for failed, cancelled or running jobs.
#' @export
collect_simulation <- function(job) {
  status <- simulation_status(job)
  if (status$state != "completed") fail(paste("simulation", status$state,
    if (!is.null(status$message)) status$message else ""), "otd_job_error")
  job$collected <- TRUE
  job$process$get_result()$result
}
#' Cancel an active simulation and discard partial output
#' @param job A simulation job.
#' @return Job status invisibly. Already completed results are retained.
#' @export
cancel_simulation <- function(job) {
  check_job(job)
  if (job$process$is_alive()) {
    terminate_worker(job$process)
    job$cancelled <- TRUE
  }
  invisible(simulation_status(job))
}

# A child may disappear between ps's process enumeration and signal delivery.
# Handle only that race; permission and other termination failures must surface.
terminate_worker <- function(process) {
  tryCatch(process$kill_tree(),no_such_process=function(e){
    if(process$is_alive())process$kill()
  })
  process$wait(timeout=1000)
  if(process$is_alive())fail("Worker termination could not be confirmed; retry cancellation.","otd_job_error")
  invisible(TRUE)
}
