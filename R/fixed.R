fixed_engine <- function(spec, n = NULL) {
  check_spec(spec)
  alternative <- if (spec$alternative == "two.sided") "two.sided" else "one.sided"
  target <- if (is.null(n)) spec$power else NULL
  if (spec$endpoint == "normal") {
    stats::power.t.test(n = n, delta = abs(spec$effect), sd = spec$sd,
      sig.level = spec$alpha, power = target, type = "two.sample",
      alternative = alternative, strict = TRUE)
  } else {
    # stats assumes p1 > p2 for the directional alternative.
    probs <- sort(c(spec$p_control, spec$p_control + spec$effect), decreasing = TRUE)
    stats::power.prop.test(n = n, p1 = probs[1], p2 = probs[2],
      sig.level = spec$alpha, power = target, alternative = alternative, strict = TRUE)
  }
}
#' Calculate fixed sample size
#' @param spec A trial_spec object.
#' @return An otd_result with integer per-arm size and achieved analytical power.
#' @export
#' @examples
#' sample_size(trial_spec(effect = 0.5))
sample_size <- function(spec) {
  raw <- fixed_engine(spec)
  n <- max(2,ceiling(raw$n))
  x<-result("fixed sample size", list(n_per_arm = n, n_total = 2 * n,
    unrounded_n_per_arm = raw$n, achieved_power = fixed_engine(spec, n)$power),
    spec, "stats", raw$method,
    c("equal allocation; independent observations", "normal: common variance t test",
      "binary: asymptotic normal approximation; no continuity correction"))
  attach_binary_diagnostics(x,spec,n)
}
#' Calculate analytical power at an integer sample size
#' @param spec A trial_spec object.
#' @param n_per_arm Integer sample size in each arm, at least two.
#' @return An otd_result with analytical power.
#' @export
#' @examples
#' trial_power(trial_spec(), 64)
trial_power <- function(spec, n_per_arm) {
  integer_count(n_per_arm, "n_per_arm", 2)
  raw <- fixed_engine(spec, n_per_arm)
  x<-result("analytical power", list(power = raw$power, n_per_arm = n_per_arm),
    spec, "stats", raw$method, "equal allocation; see trial_spec assumptions")
  attach_binary_diagnostics(x,spec,n_per_arm)
}
