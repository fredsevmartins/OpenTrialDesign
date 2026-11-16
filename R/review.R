#' Describe the scientific contract before executing a project
#'
#' This is a specification review, not scientific validation or an execution.
#' Engine domain checks still apply when the project is executed. Symbols refer
#' to treatment minus control for means/risk differences and treatment/control
#' for hazard ratios. The project is not altered and no RNG is consumed.
#' @param project A portable trial project.
#' @return A two-column data frame of review fields and values.
#' @export
#' @examples
#' review_project(trial_project())
review_project <- function(project) {
  check_project(project);p<-project$parameters;w<-project$workflow
  text<-function(x)paste(x,collapse=", ")
  fields<-list(Workflow=w,Review="Specification review only; engine checks occur on execution",
    Validation="No independent scientific or protocol-specific validation is claimed",
    Allocation="1:1 control:treatment")
  if(w%in%c("means_design","means_simulation")){
    fields$Allocation<-if(w=="means_design"&&is.null(p$n_control))paste("Planned treatment/control ratio",p$allocation_ratio) else
      paste("Treatment",p$n_treatment,"; control",p$n_control)
    fields<-c(fields,list(Estimand="Treatment minus control normal mean",Effect=text(p$effect),Nuisance=paste("Common SD",p$sd),
      Hypothesis=if(p$hypothesis=="equivalence")paste("H0: effect <=",p$lower,"OR effect >=",p$upper,"; H1: strictly inside both bounds") else
        if(p$hypothesis=="noninferiority")if(p$alternative=="greater")paste("H0: effect <=",-p$margin,"; H1: effect >",-p$margin) else
          paste("H0: effect >=",p$margin,"; H1: effect <",p$margin) else switch(p$alternative,
          greater="H0: effect <= 0; H1: effect > 0",less="H0: effect >= 0; H1: effect < 0",two.sided="H0: effect = 0; H1: effect != 0"),
      Alpha=paste(p$alpha,if(p$hypothesis=="equivalence")"per one-sided TOST component; global IUT level alpha, not 2*alpha" else
        if(p$alternative=="two.sided")"total two-sided" else "one-sided"),
      Stopping="One fixed final analysis; no sequential or adaptive extension",
      Margins="Prespecify and clinically justify margins; equivalence is not inferred from a nonsignificant superiority test",
      Assumptions="Independent normal groups, common variance; rpact t approximation for NI/superiority, PowerTOST exact TOST power for equivalence"))
  } else if(w=="nonph_simulation"){
    fields$Allocation<-paste(p$allocation_treatment,":",p$allocation_control,"treatment:control block allocation")
    fields<-c(fields,list(Estimand="Prespecified survival hazard profiles; logrank decision contrast, no constant HR estimand",
      Hypothesis="Equal-curve null and specified alternative profiles; one-sided logrank targeting lower treatment hazards",
      Alpha=paste(p$alpha,"one-sided"),Intervals=text(p$times),Control_hazards=text(p$lambda_control),Treatment_hazards=text(p$lambda_treatment),
      Recruitment=paste("Uniform recruitment over",p$accrual,"; maximum enrollment",p$n_total),
      Stopping=paste("One analysis at",p$events,"events; no administrative follow-up cap; abort if any target is unreached"),
      Nuisance=paste("Independent dropout",p$dropout,"by time",p$dropout_time),
      Assumptions="Native rpact piecewise exponential survival; rates depend on follow-up time; final interval unbounded",
      Limitations="Crossing hazards: logrank may have poor power; rejection is not uniform survival dominance; no Schoenfeld sample size"))
  } else if(startsWith(w,"fixed_")){
    symbol<-if(p$endpoint=="normal")"mean difference" else "risk difference"
    hypothesis<-switch(p$alternative,greater="H0: effect <= 0; H1: effect > 0",less="H0: effect >= 0; H1: effect < 0",
      two.sided="H0: effect = 0; H1: effect != 0")
    fields<-c(fields,list(Estimand=paste("Treatment minus control",symbol),Hypothesis=hypothesis,
      Alpha=paste(p$alpha,if(p$alternative=="two.sided")"total, two-sided" else "one-sided"),
      Effect=text(p$effect),Nuisance=if(p$endpoint=="normal")paste("Common SD",p$sd) else
        paste("Control risk",p$p_control,"; treatment risk",p$p_control+p$effect),
      Stopping="One final analysis; no interim stopping",
      Assumptions=if(p$endpoint=="normal")"Independent normal observations; common variance; pooled t test" else
        "Independent Bernoulli observations; asymptotic score approximation without continuity correction; sparse counts may be poorly calibrated"))
  } else if(w%in%c("sequential_design","sequential_means")){
    fields<-c(fields,list(Estimand=if(w=="sequential_means")"Treatment minus control normal mean" else "Positive canonical drift (no endpoint-specific enrollment)",
      Hypothesis="H0: effect <= 0; H1: effect > 0",Alpha=paste(p$alpha,"one-sided upper efficacy tail"),
      Engine=if(w=="sequential_means")"rpact; integer stages recalibrated in rpact" else p$engine,
      Information=text(p$information),Spending=p$spending,
      Stopping=paste("Upper efficacy boundary; futility:",p$futility),
      Futility=switch(p$futility,binding="Binding: must be followed to retain the design's error control",
        nonbinding="Nonbinding: may be ignored for type I error protection; enforcing it changes actual power and enrollment",none="No futility stopping"),
      Assumptions="Prespecified information looks; canonical independent increments; no adaptive resizing"))
    if(w=="sequential_means")fields<-c(fields,list(Effect=text(p$effect),Nuisance=paste("Common SD",p$sd)))
  } else if(w=="adaptive_simulation"){
    fields<-c(fields,list(Estimand="Treatment minus control normal mean",Hypothesis="H0: effect <= 0; H1: effect > 0",
      Alpha=paste(p$alpha,"one-sided"),Effect=text(p$effect),Nuisance=paste("Common SD",p$sd),
      Stopping="Two-stage inverse-normal efficacy stopping; no futility rule",
      Adaptation=paste("First-stage total",p$stage1,"; planned total",p$planned_total,
        "; additional stage-two bounds",p$min_stage2,"to",p$max_stage2,"; target conditional power",p$target_cp),
      Assumptions="Independent normal stage data; native rpact conditional-power resizing; combination weights remain prespecified",
      Scenarios="Equality null and alternative are both evaluated"))
  } else if(startsWith(w,"survival_")){
    fields<-c(fields,list(Estimand="Treatment/control hazard ratio",Hypothesis="H0: HR >= 1; H1: HR < 1",
      Alpha=paste(p$alpha,"one-sided lower-tail benefit"),Effect=paste("Alternative HR",p$hazard_ratio),
      Nuisance=paste("Control median",p$median_control,"; independent dropout",p$dropout,"by time",p$dropout_time),
      Recruitment=paste("Uniform accrual",p$accrual,"; additional follow-up",p$followup,"; all times use one common unit"),
      Stopping=if(w=="survival_design")"Fixed design event/enrollment planning; no interim efficacy stopping" else if(is.null(p$events))
        "Administrative cutoff at accrual + follow-up" else paste("At",p$events,"events or administrative cap, whichever occurs first"),
      Assumptions="Exponential proportional hazards; equal allocation; independent dropout and administrative censoring; asymptotic Schoenfeld/logrank procedure"))
  } else {
    catalog<-utils::read.csv(system.file("examples/catalog.csv",package="OpenTrialDesign"))
    row<-catalog[catalog$id==p$id,,drop=FALSE]
    fields<-c(fields,list(Example=p$id,Definition=if(nrow(row))paste(unlist(row),collapse="; ") else "Unknown example; execution will reject it",
      Scope="Version-1 repository catalog; mapping to the unavailable external plan is not established"))
    fields$Allocation<-"See the selected example's explicit specification"
  }
  if(startsWith(w,"fixed_")&&p$endpoint=="binary"&&!is.null(p$n_per_arm)){
    probabilities<-if(isTRUE(p$null))rep(p$p_control,2) else c(p$p_control,p$p_control+p$effect)
    minimum<-min(p$n_per_arm*c(probabilities,1-probabilities))
    fields$Expected_cell_counts<-paste("Minimum expected successes/failures per arm:",signif(minimum,4),
      if(minimum<5)"; sparse counts: asymptotic calibration may be poor" else "; this count diagnostic does not establish calibration")
  }
  if(!is.null(p$binary_test))fields$Binary_analysis<-if(p$binary_test=="fisher")"Explicit conditional Fisher exact test; sample size planning remains asymptotic" else "Uncorrected asymptotic score test"
  if(!is.null(p$power))fields$Target_power<-text(p$power)
  if(!is.null(p$n_per_arm))fields$Enrollment<-paste(p$n_per_arm,"per arm")
  if(!is.null(p$null))fields$Scenario<-if(p$null)"Equality null" else "Alternative"
  if(!is.null(p$nsim))fields$Monte_Carlo<-paste(p$nsim,"replications per scenario; marginal exact binomial 95% intervals and MCSE")
  if(!is.null(p$seed))fields$Seed<-text(p$seed)
  data.frame(field=gsub("_"," ",names(fields)),value=unname(vapply(fields,text,character(1))),row.names=NULL)
}
