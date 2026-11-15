library(OpenTrialDesign)
plan <- sequential_sample_size()
native <- rpact::getSimulationMeans(plan$data$design, groups=2,
  normalApproximation=FALSE, alternative=c(0,.5), stDev=1,
  plannedSubjects=plan$data$stage_plan$n_total, allocationRatioPlanned=1,
  maxNumberOfIterations=5000, seed=2026)
observed <- as.numeric(native$overallReject)
expected <- c(.025,plan$data$achieved_power)
tolerance <- 4*sqrt(expected*(1-expected)/5000)
ci <- vapply(round(observed*5000),function(k)unname(stats::binom.test(k,5000)$conf.int),numeric(2))
checks <- data.frame(scenario=c("integer sequential equality null","integer sequential alternative"),
  expected=expected,observed=observed,nsim=5000,seed=2026,
  mcse=sqrt(observed*(1-observed)/5000),lower=ci[1,],upper=ci[2,],
  tolerance=tolerance,passed=abs(observed-expected)<=tolerance,
  method="rpact normalApproximation=FALSE; actual integer information recalibrated; four theoretical MCSE")
print(plan);print(native);print(checks)
utils::write.csv(checks,"validation/product-scientific-reference.csv",row.names=FALSE)
stopifnot(all(checks$passed))
print(sessionInfo())
