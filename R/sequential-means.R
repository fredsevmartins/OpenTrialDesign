#' Plan integer-enrollment sequential normal means using rpact
#'
#' Positive treatment minus control superiority, equal allocation, common
#' variance and rpact's t-distribution planning approximation are assumed.
#' Each cumulative per-arm size is rounded upward. The spending design is
#' recalibrated at the resulting information fractions using the same engine;
#' achieved power is recomputed and enrollment increased if needed. Boundaries
#' are never transferred from gsDesign. This is planning, not interim inference.
#' @param effect Positive treatment minus control mean.
#' @param sd Common standard deviation.
#' @inheritParams sequential_design
#' @return An otd_result with integer cumulative stage sizes, recalibrated
#'   boundaries, native rpact output, and achieved planning power.
#' @export
#' @examples
#' if (requireNamespace("rpact", quietly = TRUE)) sequential_sample_size()
sequential_sample_size <- function(effect = 0.5, sd = 1, information = c(0.5, 1),
                                   alpha = 0.025, power = 0.8, spending = "OF",
                                   futility = "none") {
  scalar(effect, "effect", 0, Inf); scalar(sd, "sd", 0, Inf)
  requested <- sequential_design("rpact", information, alpha, power, spending, futility)
  raw <- rpact::getSampleSizeMeans(requested$data$native, alternative = effect,
    stDev = sd, normalApproximation = FALSE, allocationRatioPlanned = 1)
  n <- max(ceiling(as.numeric(raw$maxNumberOfSubjects)/2), ceiling(2/min(information)))
  for (iteration in seq_len(500)) {
    integer_count(n, "maximum per-arm enrollment", 2)
    stages <- ceiling(n * information)
    if (all(diff(stages) > 0)) {
      realized <- stages/n
      d <- sequential_design("rpact", realized, alpha, power, spending, futility)
      achieved <- rpact::getPowerMeans(d$data$native, alternative = effect,
        stDev = sd, normalApproximation = FALSE, directionUpper = TRUE,
        maxNumberOfSubjects = 2*n, allocationRatioPlanned = 1)
      p <- as.numeric(achieved$overallReject)
      if (length(p) == 1 && is.finite(p) && p >= power - 1e-8) break
    }
    n <- n+1
  }
  if (iteration == 500) fail("integer sequential plan did not converge", "otd_engine_error")
  result("sequential mean sample size", list(n_per_arm = n, n_total = 2*n,
    achieved_power = p, stage_plan = data.frame(stage = seq_along(stages),
      n_per_arm = stages, n_total = 2*stages, information = realized),
    boundaries = d$data$boundaries, native = achieved, design = d$data$native),
    list(effect = effect, sd = sd, requested_information = information,
      realized_information = realized, alpha = alpha, power = power,
      spending = spending, futility = futility, estimand = "treatment minus control mean"),
    "rpact", "native t-approximation planning with same-engine spending recalibration",
    c("equal allocation; independent normal observations; common variance",
      "one-sided upper efficacy; requested information fractions may change after rounding",
      paste("futility:", futility), "analytical planning approximation; not Monte Carlo"))
}
