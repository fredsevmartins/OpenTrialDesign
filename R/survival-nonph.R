#' Evaluate piecewise exponential nonproportional hazards with native rpact simulation
#'
#' Hazards are rates per subject follow-up time, not calendar time. Each vector
#' has one positive rate for every interval starting in times. The final interval
#' is unbounded. Equal-curve null and alternative profiles are both simulated.
#' This evaluates an ordinary one-sided logrank decision; it does not estimate
#' a constant hazard ratio, assert benefit at every time, or provide Schoenfeld
#' sample size under non-PH. For crossing hazards its power may be poor and its
#' rejection must not be interpreted as uniform survival dominance.
#'
#' The native engine follows recruitment until the event analysis, with no
#' additional administrative follow-up cap. If any replication fails to reach
#' the event target, this adapter aborts: native getData omits those trials and
#' a valid full-denominator operating characteristic cannot be reconstructed
#' without an explicitly specified alternative analysis rule.
#' @param times Increasing interval start times, beginning at zero.
#' @param lambda_control,lambda_treatment Positive piecewise hazard vectors.
#' @param n_total Maximum total enrollment; multiple of the allocation block.
#' @param events Planned final event count, less than n_total.
#' @param allocation_treatment,allocation_control Small integer block allocation counts.
#' @param accrual Duration of uniform accrual.
#' @param dropout Independent dropout probability by dropout_time in both arms.
#' @param dropout_time Duration defining the dropout probability.
#' @param alpha One-sided logrank efficacy alpha, targeting lower treatment hazards.
#' @param nsim Replications per profile scenario.
#' @param seed Deterministic seed; alternative uses seed+1.
#' @return An otd_result with null and alternative Monte Carlo uncertainty.
#' @export
#' @examples
#' if(requireNamespace("rpact",quietly=TRUE)) simulate_nonph(nsim=20)
simulate_nonph <- function(times=c(0,6),lambda_control=c(.06,.06),lambda_treatment=c(.06,.03),
                           n_total=200,events=100,allocation_treatment=1,allocation_control=1,
                           accrual=12,dropout=0,dropout_time=12,alpha=.025,nsim=1000,seed=2026) {
  need("rpact")
  if(!is.numeric(times)||!length(times)||any(!is.finite(times))||times[1]!=0||any(diff(times)<=0))
    fail("times must be finite, start at zero and increase strictly")
  for(key in c("lambda_control","lambda_treatment")){
    v<-get(key)
    if(!is.numeric(v)||length(v)!=length(times)||any(!is.finite(v))||any(v<=0))fail(paste(key,"must contain one positive hazard per time interval"))
  }
  integer_count(n_total,"n_total",4);integer_count(events,"events",2)
  if(events>=n_total)fail("events must be less than total enrollment")
  for(key in c("allocation_treatment","allocation_control")){
    integer_count(get(key),key)
    if(get(key)>20)fail("Use small allocation block counts (maximum 20 per arm)")
  }
  if(n_total%%(allocation_treatment+allocation_control)!=0)fail("n_total must be a multiple of the allocation block")
  scalar(accrual,"accrual",0,Inf);scalar(dropout_time,"dropout_time",0,Inf)
  scalar(dropout,"dropout",-Inf,1);if(dropout<0)fail("dropout must be nonnegative")
  scalar(alpha,"alpha",0,.5);integer_count(nsim,"nsim",2);integer_count(seed,"seed",0);integer_count(seed+1,"alternative seed",0)
  d<-rpact::getDesignGroupSequential(kMax=1,alpha=alpha,sided=1)
  natives<-list();rows<-list()
  for(i in 1:2){
    name<-c("equal-curve null","alternative profile")[i]
    hazards<-if(i==1)lambda_control else lambda_treatment
    native<-withr::with_seed(seed+i-1,rpact::getSimulationSurvival(d,
      piecewiseSurvivalTime=times,lambda1=hazards,lambda2=lambda_control,
      directionUpper=FALSE,plannedEvents=events,maxNumberOfSubjects=n_total,
      allocation1=allocation_treatment,allocation2=allocation_control,
      accrualTime=c(0,accrual),accrualIntensityType="relative",
      dropoutRate1=dropout,dropoutRate2=dropout,dropoutTime=dropout_time,
      maxNumberOfIterations=nsim,seed=seed+i-1,longTimeSimulationAllowed=TRUE))
    raw<-rpact::getData(native);raw<-raw[raw$trialStop,,drop=FALSE]
    if(nrow(raw)!=nsim||anyNA(raw$eventsNotAchieved)||any(raw$eventsNotAchieved!=0))
      fail(paste("Event target was not attained in every replication of",name,
        "; native data omit unreached analyses. Increase enrollment or reduce events/dropout; no partial estimate returned."),"otd_simulation_error")
    rejections<-sum(raw$rejectPerStage)
    if(!is.finite(rejections)||abs(rejections/nsim-as.numeric(native$overallReject))>1e-8)
      fail("Native rejection counts disagree with full-denominator output","otd_engine_error")
    if(any(!is.finite(raw$analysisTime)))fail("Native event-analysis times are not finite","otd_engine_error")
    if(any(!is.finite(raw$numberOfSubjects)))fail("Native realized enrollment is not finite","otd_engine_error")
    ci<-mc_binomial(rejections,nsim);duration<-mc_mean(raw$analysisTime);enrolled<-mc_mean(raw$numberOfSubjects);attainment<-mc_binomial(nsim,nsim)
    rows[[i]]<-data.frame(scenario=name,nsim=nsim,seed=seed+i-1,rejections=rejections,
      estimate=ci["estimate"],mcse=ci["mcse"],lower=ci["lower"],upper=ci["upper"],
      mean_analysis_time=duration["estimate"],time_mcse=duration["mcse"],time_lower=duration["lower"],
      time_upper=duration["upper"],mean_enrolled=enrolled["estimate"],enrolled_mcse=enrolled["mcse"],
      enrolled_lower=enrolled["lower"],enrolled_upper=enrolled["upper"],target_attainment=1,target_mcse=attainment["mcse"],
      target_lower=attainment["lower"],target_upper=attainment["upper"],row.names=NULL)
    natives[[name]]<-native
  }
  spec<-list(times=times,lambda_control=lambda_control,lambda_treatment=lambda_treatment,
    n_total=n_total,events=events,allocation_treatment=allocation_treatment,allocation_control=allocation_control,
    accrual=accrual,dropout=dropout,dropout_time=dropout_time,alpha=alpha,
    estimand="prespecified survival hazard profiles; logrank decision contrast, no constant-HR estimand",
    stopping="single event-driven final analysis; no administrative follow-up cap")
  result("nonproportional hazards operating characteristics",list(summary=do.call(rbind,rows),native=natives),
    spec,"rpact","native piecewise-exponential generation and one-sided logrank analysis",
    c("piecewise hazards depend on follow-up time; uniform recruitment; independent dropout",
      "n_total is maximum enrollment; recruitment can stop early when the event target is reached",
      "ordinary logrank is not an optimal or uniformly beneficial test under crossing hazards",
      "equal-curve null only; no proof for a composite non-PH null or constant-HR estimation",
      "all event targets must be attained; failed analyses are never removed from a Monte Carlo denominator",
      "exact binomial rejection intervals; approximate t-based Monte Carlo intervals for mean analysis time"),seed)
}
