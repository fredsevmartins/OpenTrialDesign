#' Estimate operating characteristics with Monte Carlo uncertainty
#'
#' Normal trials use the pooled two-sample t test. Binary trials use the
#' uncorrected Pearson score test via prop.test; its discrete finite-sample
#' behavior need not agree exactly with asymptotic planning power. Failed tests
#' abort rather than silently changing the Monte Carlo denominator.
#' @param spec A trial_spec object.
#' @param n_per_arm Integer size in each arm.
#' @param nsim Number of independent replications.
#' @param seed Deterministic integer seed.
#' @param null If TRUE simulate the equality null (effect zero).
#' @return An otd_result with rejection proportion, MCSE and exact binomial interval.
#' @export
#' @examples
#' simulate_trial(trial_spec(), 64, nsim = 100, seed = 42)
simulate_trial <- function(spec, n_per_arm, nsim = 1000, seed = 1, null = FALSE) {
  check_spec(spec); integer_count(n_per_arm, "n_per_arm", 2)
  integer_count(nsim, "nsim", 2); integer_count(seed, "seed", 0)
  if (!is.logical(null) || length(null) != 1 || is.na(null)) fail("null must be TRUE or FALSE")
  effect <- if (null) 0 else spec$effect
  rejected <- withr::with_seed(seed, replicate(nsim, {
    if (spec$endpoint == "normal") {
      control <- stats::rnorm(n_per_arm, 0, spec$sd)
      treatment <- stats::rnorm(n_per_arm, effect, spec$sd)
      p <- stats::t.test(treatment, control, var.equal = TRUE,
        alternative = spec$alternative)$p.value
    } else {
      counts <- c(stats::rbinom(1, n_per_arm, spec$p_control + effect),
                  stats::rbinom(1, n_per_arm, spec$p_control))
      # With no successes or no failures the score statistic is undefined;
      # these identical outcomes provide no evidence against equality.
      p <- if (sum(counts) %in% c(0, 2 * n_per_arm)) 1 else
        suppressWarnings(stats::prop.test(counts, rep(n_per_arm, 2),
          alternative = spec$alternative, correct = FALSE)$p.value)
    }
    if (!is.finite(p)) fail("nonfinite simulation p-value", "otd_simulation_error")
    p <= spec$alpha
  }))
  oc_result(sum(rejected), nsim, spec, "stats", seed,
            if (null) "empirical type I error at equality null" else "empirical power",
            list(n_per_arm = n_per_arm, effect_simulated = effect))
}
oc_result <- function(rejections, nsim, spec, engine, seed, method, extra = list()) {
  estimate <- rejections / nsim
  ci <- unname(stats::binom.test(rejections, nsim)$conf.int)
  result("Monte Carlo operating characteristics", c(list(rejections = rejections,
    nsim = nsim, estimate = estimate, mcse = sqrt(estimate * (1 - estimate) / nsim),
    conf_level = 0.95, lower = ci[1], upper = ci[2]), extra), spec, engine, method,
    "independent replications; exact Clopper-Pearson 95% interval; no multiplicity adjustment", seed)
}

# Monte Carlo uncertainty of a simulation mean; t interval is approximate.
mc_mean <- function(x) {
  estimate <- mean(x)
  se <- stats::sd(x)/sqrt(length(x))
  half <- stats::qt(0.975, df = length(x)-1)*se
  c(estimate = estimate, mcse = se, lower = estimate-half, upper = estimate+half)
}
mc_binomial <- function(k, n) {
  p <- k/n
  ci <- unname(stats::binom.test(k, n)$conf.int)
  c(estimate = p, mcse = sqrt(p*(1-p)/n), lower = ci[1], upper = ci[2])
}
