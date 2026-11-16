#' Inspect expected binary counts and approximation limitations
#'
#' The count threshold of five is a descriptive screening heuristic, not a
#' theorem establishing calibration. Increasing the number of simulations
#' improves Monte Carlo precision but does not repair an approximate test.
#' @param spec A binary trial_spec.
#' @param n_per_arm Integer participants in each arm.
#' @param null Whether to inspect the equality-null probabilities.
#' @return A list with expected counts, sparse flag and methodological guidance.
#' @export
binary_diagnostics <- function(spec,n_per_arm,null=FALSE) {
  check_spec(spec)
  if(spec$endpoint!="binary")fail("binary_diagnostics requires a binary endpoint")
  integer_count(n_per_arm,"n_per_arm",2)
  if(!is.logical(null)||length(null)!=1||is.na(null))fail("null must be logical")
  probabilities<-c(spec$p_control,spec$p_control+if(null)0 else spec$effect)
  counts<-data.frame(arm=c("control","treatment"),n=n_per_arm,probability=probabilities,
    expected_successes=n_per_arm*probabilities,expected_failures=n_per_arm*(1-probabilities))
  minimum<-min(counts$expected_successes,counts$expected_failures)
  list(scenario=if(null)"equality null" else "alternative",expected_counts=counts,
    minimum_expected_count=minimum,sparse=minimum<5,
    status=if(minimum<5)"Sparse expected counts: asymptotic calibration may be poor" else
      "Count screen does not establish test calibration",
    guidance=c("Five expected observations per cell is a screening heuristic, not validation.",
      "Score planning and score simulation are asymptotic and may be conservative or anti-conservative in finite samples.",
      "Fisher simulation is an explicit conditional exact-test alternative; it does not convert approximate planning into exact sample size.",
      "Evaluate both null error and alternative power at the actual integer enrollment; report Monte Carlo uncertainty.",
      "More replications reduce Monte Carlo uncertainty; they do not fix test miscalibration."))
}
attach_binary_diagnostics <- function(x,spec,n,null=FALSE) {
  if(spec$endpoint=="binary")x$diagnostics<-binary_diagnostics(spec,n,null)
  x
}
