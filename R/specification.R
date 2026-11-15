#' Specify a fixed sample superiority trial
#'
#' Equal allocation, independent observations and a common normal standard
#' deviation are assumed for means. Binary calculations use the normal
#' approximation in stats::power.prop.test, without continuity correction.
#' The effect is treatment minus control; a one-sided test targets improvement
#' in the explicitly specified direction. Alpha is total type I error.
#' @param endpoint Either "normal" or "binary".
#' @param effect Treatment minus control mean, or risk difference.
#' @param sd Common standard deviation (normal endpoint).
#' @param p_control Control response probability (binary endpoint).
#' @param alpha Total type I error probability.
#' @param power Target power.
#' @param alternative Either "two.sided", "greater" or "less".
#' @return A validated otd_spec list.
#' @export
#' @examples
#' trial_spec(effect = 0.5)
trial_spec <- function(endpoint = c("normal", "binary"), effect = 0.5,
                       sd = 1, p_control = 0.3, alpha = 0.05,
                       power = 0.8, alternative = c("two.sided", "greater", "less")) {
  endpoint <- match.arg(endpoint); alternative <- match.arg(alternative)
  scalar(alpha, "alpha", 0, 1); scalar(power, "power", alpha, 1)
  scalar(effect, "effect", -Inf, Inf)
  if (effect == 0) fail("effect must be nonzero for sample size planning")
  if ((alternative == "greater" && effect < 0) ||
      (alternative == "less" && effect > 0)) fail("effect contradicts hypothesis direction")
  if (endpoint == "normal") scalar(sd, "sd", 0, Inf)
  if (endpoint == "binary") {
    scalar(p_control, "p_control", 0, 1)
    scalar(p_control + effect, "treatment probability", 0, 1)
  }
  structure(list(endpoint = endpoint, effect = effect, sd = sd,
    p_control = p_control, alpha = alpha, power = power,
    alternative = alternative, allocation = c(control = 1, treatment = 1),
    estimand = "treatment minus control", hypothesis = "superiority"), class = "otd_spec")
}

fail <- function(message, class = "otd_input_error") {
  stop(structure(list(message = message, call = NULL),
    class = c(class, "error", "condition")))
}
scalar <- function(x, name, lower, upper) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
      x <= lower || x >= upper) fail(paste(name, "must be finite and strictly between", lower, "and", upper))
  invisible(x)
}
integer_count <- function(x, name, minimum = 1) {
  scalar(x, name, minimum - 1, .Machine$integer.max)
  if (x != floor(x)) fail(paste(name, "must be an integer"))
}
check_spec <- function(spec) {
  if (!inherits(spec, "otd_spec")) fail("spec must come from trial_spec")
  rebuilt <- do.call(trial_spec, spec[c("endpoint", "effect", "sd", "p_control", "alpha", "power", "alternative")])
  if (!identical(spec, rebuilt)) fail("spec was modified; construct a new trial_spec")
}
need <- function(package) {
  if (!requireNamespace(package, quietly = TRUE))
    fail(paste("Install optional dependency", package), "otd_dependency_error")
}
provenance <- function(engine, method, assumptions, seed = NULL) {
  packages <- unique(c("OpenTrialDesign", engine))
  versions <- vapply(packages, function(p) {
    if (requireNamespace(p, quietly = TRUE)) as.character(utils::packageVersion(p)) else "uninstalled"
  }, character(1))
  list(engine = engine, method = method, assumptions = assumptions, seed = seed,
       versions = versions, R = R.version.string, rng = RNGkind(),
       validation = "execution is not independent scientific validation")
}
result <- function(kind, data, spec, engine, method, assumptions, seed = NULL) {
  structure(list(kind = kind, data = data, specification = spec,
    provenance = provenance(engine, method, assumptions, seed)), class = "otd_result")
}
