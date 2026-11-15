#' Simulate a two-stage adaptive inverse-normal combination test
#'
#' Uses rpact's inverse-normal design and its native conditional-power sample
#' size recalculation. Combination weights remain the prespecified information
#' weights even when stage-two enrollment changes. Independent normally
#' distributed stage data, equal allocation and the engine normal approximation
#' are assumed. This is a one-sided superiority procedure with no futility
#' boundary. It is not an ordinary pooled test after unblinded resizing.
#' Both equality-null and alternative scenarios are always simulated.
#' @param effect Positive alternative treatment minus control mean.
#' @param sd Common standard deviation.
#' @param stage1 Total first-stage enrollment, even integer.
#' @param planned_total Initially planned total enrollment, even integer.
#' @param min_stage2 Minimum additional stage-two enrollment, even integer.
#' @param max_stage2 Maximum additional stage-two enrollment, even integer.
#' @param target_cp Target conditional power for native rpact recalculation.
#' @param alpha One-sided type I error.
#' @param power Design target power used to define combination boundaries.
#' @param nsim Replications per scenario.
#' @param seed Integer seed.
#' @return An otd_result with native simulation, null/alternative MC uncertainty.
#' @export
#' @examples
#' if (requireNamespace("rpact", quietly = TRUE)) adaptive_simulation(nsim = 100)
adaptive_simulation <- function(effect = 0.5, sd = 1, stage1 = 80,
                                planned_total = 160, min_stage2 = 40,
                                max_stage2 = 240, target_cp = 0.8,
                                alpha = 0.025, power = 0.8,
                                nsim = 1000, seed = 1) {
  need("rpact"); scalar(effect, "effect", 0, Inf); scalar(sd, "sd", 0, Inf)
  for (name in c("stage1", "planned_total", "min_stage2", "max_stage2")) {
    x <- get(name); integer_count(x, name, 4)
    if (x %% 2 != 0) fail(paste(name, "must be even for equal allocation"))
  }
  if (planned_total <= stage1 || min_stage2 > max_stage2 ||
      planned_total-stage1 < min_stage2 || planned_total-stage1 > max_stage2)
    fail("planned enrollment and stage-two limits are inconsistent")
  scalar(target_cp, "target_cp", 0, 1); scalar(alpha, "alpha", 0, 0.5)
  scalar(power, "power", alpha, 1); integer_count(nsim, "nsim", 2)
  integer_count(seed, "seed", 0)
  spec <- list(effect = effect, sd = sd, stage1 = stage1, planned_total = planned_total,
    min_stage2 = min_stage2, max_stage2 = max_stage2, target_cp = target_cp,
    alpha = alpha, power = power, combination_information = c(stage1/planned_total, 1))
  design <- rpact::getDesignInverseNormal(kMax = 2, alpha = alpha, beta = 1-power,
    sided = 1, informationRates = spec$combination_information, typeOfDesign = "asOF")
  native <- withr::with_seed(seed, rpact::getSimulationMeans(design,
    groups = 2, normalApproximation = TRUE, alternative = c(0, effect), stDev = sd,
    thetaH0 = 0, directionUpper = TRUE, allocationRatioPlanned = 1,
    plannedSubjects = c(stage1, planned_total), conditionalPower = target_cp,
    minNumberOfSubjectsPerStage = c(stage1, min_stage2),
    maxNumberOfSubjectsPerStage = c(stage1, max_stage2),
    maxNumberOfIterations = nsim, seed = seed))
  p <- as.numeric(native$overallReject)
  if (length(p) != 2 || any(!is.finite(p))) fail("unexpected rpact simulation output", "otd_engine_error")
  counts <- round(p * nsim)
  if (any(abs(p * nsim-counts) > 1e-6)) fail("rpact rejection output incompatible with replication count", "otd_engine_error")
  cis <- vapply(counts, function(k) unname(stats::binom.test(k, nsim)$conf.int), numeric(2))
  summary <- data.frame(scenario = c("equality null", "alternative"),
    effect = c(0, effect), nsim = nsim, rejections = counts, estimate = p,
    mcse = sqrt(p*(1-p)/nsim), lower = cis[1,], upper = cis[2,],
    expected_n = as.numeric(native$expectedNumberOfSubjects))
  result("adaptive inverse normal simulation", list(summary = summary, native = native,
    design = design), spec, "rpact", "native inverse-normal combination test with conditional-power resizing",
    c("one-sided positive mean effect; independent normal stage data",
      "prespecified inverse-normal combination weights; equal allocation",
      "no futility rule; bounded stage-two enrollment; exact binomial 95% intervals"), seed)
}
