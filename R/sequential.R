#' Create a one-sided group sequential design
#'
#' Uses engine-native spending functions. Alpha is the upper efficacy-tail
#' error; a lower futility crossing never rejects the null. The gsDesign
#' adapter uses test.type 1 (no futility), 3 (binding), or 4 (nonbinding).
#' rpact uses beta spending for futility with explicit bindingFutility.
#' Different engines' O'Brien-Fleming approximations are not interchangeable.
#' @param engine Either "gsDesign" or "rpact".
#' @param information Strictly increasing information fractions ending at 1.
#' @param alpha One-sided efficacy alpha.
#' @param power Target power.
#' @param spending Either "OF" or "Pocock" spending.
#' @param futility Either "none", "binding" or "nonbinding".
#' @return An otd_result retaining the native engine object.
#' @export
#' @examples
#' if (requireNamespace("gsDesign", quietly = TRUE)) sequential_design()
sequential_design <- function(engine = c("gsDesign", "rpact"),
                              information = c(0.5, 1), alpha = 0.025,
                              power = 0.8, spending = c("OF", "Pocock"),
                              futility = c("none", "binding", "nonbinding")) {
  engine <- match.arg(engine); spending <- match.arg(spending); futility <- match.arg(futility)
  need(engine); scalar(alpha, "alpha", 0, 0.5); scalar(power, "power", alpha, 1)
  if (!is.numeric(information) || length(information) < 2 ||
      any(!is.finite(information)) || any(diff(c(0, information)) <= 0) ||
      tail(information, 1) != 1) fail("information must increase strictly from above zero to one")
  spec <- list(engine = engine, information = information, alpha = alpha,
    power = power, spending = spending, futility = futility,
    hypothesis = "one-sided positive canonical effect; upper efficacy boundary")
  if (engine == "gsDesign") {
    native <- gsDesign::gsDesign(k = length(information),
      test.type = switch(futility, none = 1, binding = 3, nonbinding = 4),
      alpha = alpha, beta = 1-power, timing = information,
      sfu = if (spending == "OF") gsDesign::sfLDOF else gsDesign::sfLDPocock,
      sfl = gsDesign::sfHSD, sflpar = -2)
    bounds <- data.frame(information = information, efficacy = native$upper$bound,
      futility = if (futility == "none") rep(-Inf, length(information)) else native$lower$bound)
  } else {
    native <- rpact::getDesignGroupSequential(kMax = length(information),
      alpha = alpha, beta = 1-power, sided = 1, informationRates = information,
      typeOfDesign = if (spending == "OF") "asOF" else "asP",
      typeBetaSpending = if (futility == "none") "none" else "bsHSD",
      gammaB = if (futility == "none") NA_real_ else -2,
      bindingFutility = if (futility == "none") NA else futility == "binding")
    lower <- if (futility == "none") rep(-Inf, length(information)) else c(native$futilityBounds, tail(native$criticalValues, 1))
    bounds <- data.frame(information = information, efficacy = native$criticalValues, futility = lower)
  }
  result("group sequential design", list(native = native, boundaries = bounds),
    spec, engine, paste(spending, "alpha spending"),
    c("canonical independent-increments model; one-sided upper efficacy test",
      paste("futility:", futility), "information fractions prespecified; no adaptive resizing"))
}
#' Compute engine-native analytical sequential operating characteristics
#' @param design An otd_result from sequential_design using gsDesign.
#' @param theta Canonical drift, zero for the null. NULL uses the design alternative.
#' @return An otd_result containing crossing probabilities and expected information.
#' @export
sequential_power <- function(design, theta = NULL) {
  check_sequential(design)
  if (is.null(theta)) theta <- design$data$native$delta
  scalar(theta, "theta", -Inf, Inf)
  raw <- gsDesign::gsProbability(d = design$data$native, theta = theta)
  result("sequential analytical operating characteristics",
    list(rejection_probability = sum(raw$upper$prob),
      expected_information = raw$en, native = raw), design$specification,
    "gsDesign", "gsProbability numerical integration",
    "lower futility enforced in probability calculation, including nonbinding designs")
}
check_sequential <- function(design) {
  if (!inherits(design, "otd_result") || design$kind != "group sequential design" ||
      design$specification$engine != "gsDesign")
    fail("requires sequential_design(engine = 'gsDesign')")
}
#' Simulate canonical sequential boundary crossing
#' @param design A gsDesign sequential design from sequential_design.
#' @param theta Canonical drift; zero evaluates type I error.
#' @param nsim Number of replications.
#' @param seed Integer seed.
#' @param enforce_futility Whether to enforce a nonbinding futility rule.
#'   Binding futility must always be enforced.
#' @return An otd_result with rejection uncertainty and stopping summaries.
#' @export
simulate_sequential <- function(design, theta = 0, nsim = 10000, seed = 1,
                                enforce_futility = TRUE) {
  check_sequential(design); scalar(theta, "theta", -Inf, Inf)
  integer_count(nsim, "nsim", 2); integer_count(seed, "seed", 0)
  if (!is.logical(enforce_futility) || length(enforce_futility) != 1 || is.na(enforce_futility))
    fail("enforce_futility must be logical")
  if (design$specification$futility == "binding" && !enforce_futility)
    fail("binding futility cannot be ignored")
  d <- design$data$native; k <- length(d$n.I)
  z <- withr::with_seed(seed, {
    increments <- matrix(stats::rnorm(nsim*k), nsim, k)
    increments <- sweep(increments, 2, sqrt(diff(c(0, d$n.I))), "*")
    increments <- sweep(increments, 2, theta*diff(c(0, d$n.I)), "+")
    for (j in 2:k) increments[,j] <- increments[,j] + increments[,j-1]
    sweep(increments, 2, sqrt(d$n.I), "/")
  })
  active <- rep(TRUE, nsim); rejected <- rep(FALSE, nsim); stage <- rep(k, nsim)
  for (j in seq_len(k)) {
    efficacy <- active & z[,j] >= design$data$boundaries$efficacy[j]
    rejected[efficacy] <- TRUE
    futility <- if (enforce_futility) active & !efficacy & z[,j] <= design$data$boundaries$futility[j] else rep(FALSE, nsim)
    stop <- efficacy | futility
    stage[stop] <- j; active[stop] <- FALSE
  }
  oc_result(sum(rejected), nsim, design$specification, "gsDesign", seed,
    "canonical normal independent increments simulation",
    list(theta = theta, enforce_futility = enforce_futility,
      stopping_probabilities = tabulate(stage, nbins = k)/nsim,
      expected_information = mean(d$n.I[stage]),
      expected_information_uncertainty = mc_mean(d$n.I[stage]),
      stopping_uncertainty = t(vapply(seq_len(k), function(j)
        mc_binomial(sum(stage == j), nsim), numeric(4))),
      mean_interval_method = "approximate t-based 95% Monte Carlo interval",
      stopping_interval_method = "marginal exact binomial 95%; no simultaneous coverage claim"))
}
#' Conditional power at an observed interim Z statistic
#' @param design A gsDesign sequential design.
#' @param z Observed canonical Z statistic.
#' @param stage Interim stage index, strictly before final stage.
#' @param theta Canonical future drift; NULL uses the design alternative.
#' @return The native gsCP object, wrapped with provenance.
#' @export
conditional_power <- function(design, z, stage = 1, theta = NULL) {
  check_sequential(design); scalar(z, "z", -Inf, Inf)
  integer_count(stage, "stage")
  if (stage >= length(design$data$native$n.I)) fail("stage must precede final analysis")
  if (is.null(theta)) theta <- design$data$native$delta
  scalar(theta, "theta", -Inf, Inf)
  raw <- gsDesign::gsCP(design$data$native, theta = theta, i = stage, zi = z)
  result("conditional power", list(native = raw),
    c(design$specification, list(z = z, stage = stage, theta = theta)),
    "gsDesign", "gsCP", "hypothetical continuation at specified drift; not permission to resize")
}
