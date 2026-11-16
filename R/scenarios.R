#' Expand a project's assumptions into a reproducible sensitivity grid
#'
#' Every row is a complete frozen project. Simulation seeds increment by row
#' by default; preserving seeds is explicit and does not imply independent
#' scenario estimates. No statistical methods are mixed across engines.
#' @param project A project created by trial_project.
#' @param vary Named list of nonempty atomic vectors of parameter values.
#'   Vector-valued information fractions cannot be varied by this helper.
#' @param seed_strategy Increment simulation seeds by row, or preserve them.
#' @param max_scenarios Maximum grid size (at most 1000).
#' @return A named list of otd_project objects.
#' @export
#' @examples
#' projects <- scenario_grid(trial_project(), list(effect=c(.3,.5), power=c(.8,.9)))
#' run_scenarios(projects)$data$summary
scenario_grid <- function(project, vary, seed_strategy=c("increment","preserve"), max_scenarios=1000) {
  check_project(project);seed_strategy<-match.arg(seed_strategy)
  integer_count(max_scenarios,"max_scenarios")
  if(max_scenarios>1000)fail("max_scenarios cannot exceed 1000")
  if(!is.list(vary)||!length(vary)||is.null(names(vary))||anyNA(names(vary))||
     any(!nzchar(names(vary)))||anyDuplicated(names(vary)))fail("vary must be a uniquely named nonempty list")
  if(any(!names(vary)%in%project_arguments(project$workflow))||"information"%in%names(vary))
    fail("vary contains an unknown or vector-valued parameter")
  if(any(!vapply(vary,function(x)is.atomic(x)&&is.null(dim(x))&&length(x)>0&&!anyNA(x),logical(1))))
    fail("scenario values must be nonempty atomic vectors without missing values")
  if(prod(lengths(vary))>max_scenarios)fail("scenario grid exceeds max_scenarios")
  grid<-do.call(expand.grid,c(vary,list(KEEP.OUT.ATTRS=FALSE,stringsAsFactors=FALSE)))
  if("seed"%in%names(vary)&&seed_strategy=="increment")fail("Use seed_strategy='preserve' to vary seed explicitly")
  out<-lapply(seq_len(nrow(grid)),function(i){
    parameters<-project$parameters
    for(key in names(vary))parameters[[key]]<-grid[[key]][i]
    if("seed"%in%names(parameters)&&seed_strategy=="increment"){
      parameters$seed<-parameters$seed+i-1
      integer_count(parameters$seed,"scenario seed",0)
    }
    trial_project(project$workflow,parameters,paste0(substr(project$title,1,170)," / scenario ",i))
  })
  names(out)<-sprintf("S%03d",seq_along(out));out
}
check_scenarios <- function(projects) {
  if(!is.list(projects)||!length(projects)||length(projects)>1000)fail("Provide between 1 and 1000 projects")
  if(is.null(names(projects))||anyNA(names(projects))||any(!nzchar(names(projects)))||anyDuplicated(names(projects)))
    fail("Scenario projects require unique nonempty names")
  invisible(lapply(projects,check_project))
}
#' Execute scenario projects without silently discarding failed cases
#'
#' Tables retain scenario identifiers and engine/method provenance. Errors
#' abort by default. With continue_on_error, failures are separate rows, never
#' estimates or missing replications in a Monte Carlo denominator.
#' @param projects Named list of complete projects, for example from scenario_grid.
#' @param continue_on_error Whether to retain individual failures and continue.
#' @return An otd_result with summary, failures, exact projects and results.
#' @export
run_scenarios <- function(projects, continue_on_error=FALSE) {
  check_scenarios(projects)
  if(!is.logical(continue_on_error)||length(continue_on_error)!=1||is.na(continue_on_error))fail("continue_on_error must be logical")
  answers<-list();rows<-list();errors<-list()
  for(id in names(projects)){
    x<-tryCatch(execute_project(projects[[id]]),error=function(e){
      if(!continue_on_error)stop(e)
      errors[[id]]<<-data.frame(scenario=id,message=conditionMessage(e),error_class=class(e)[1]);NULL
    })
    if(is.null(x))next
    answers[[id]]<-x
    table<-result_table(x)
    # A native adapter can itself have a scenario column (e.g. adaptive null/alternative).
    if("scenario"%in%names(table))names(table)[names(table)=="scenario"]<-"within_scenario"
    rows[[id]]<-cbind(data.frame(scenario=id,workflow=projects[[id]]$workflow,
      engine=paste(x$provenance$engine,collapse=","),method=x$provenance$method,
      seed=if(is.null(x$provenance$seed))NA_real_ else x$provenance$seed),table)
  }
  bind<-function(items){
    if(!length(items))return(data.frame())
    fields<-unique(unlist(lapply(items,names)))
    do.call(rbind,lapply(items,function(x){for(k in setdiff(fields,names(x)))x[[k]]<-NA;x[fields]}))
  }
  engines<-unique(unlist(lapply(answers,function(x)x$provenance$engine)))
  result("scenario sensitivity analysis",list(summary=bind(rows),failures=bind(errors),
    results=answers,projects=projects),list(projects=projects,continue_on_error=continue_on_error),
    engines,"independent execution of frozen project specifications",
    c("scenario results retain their own engine assumptions; no cross-engine inferential combination",
      "Monte Carlo intervals are marginal; no simultaneous coverage claim; compare simulation precision before interpreting differences"))
}
#' Run a scenario grid in a cancellable background worker
#' @param projects Named list of complete projects.
#' @param continue_on_error Whether to retain individual errors and continue.
#' @return An otd_job compatible with simulation_status, collect_simulation and cancel_simulation.
#' @export
start_scenarios <- function(projects,continue_on_error=FALSE) {
  check_scenarios(projects)
  if(!is.logical(continue_on_error)||length(continue_on_error)!=1||is.na(continue_on_error))fail("continue_on_error must be logical")
  start_job(list(title="Scenario sensitivity analysis",projects=projects,continue_on_error=continue_on_error),
    function(project)OpenTrialDesign::run_scenarios(project$projects,project$continue_on_error))
}
