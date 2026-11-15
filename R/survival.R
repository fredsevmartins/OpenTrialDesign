#' Plan an exponential proportional hazards survival trial
#'
#' Delegates event and enrollment planning to rpact using Schoenfeld's
#' approximation. Hazard ratio is treatment/control; less than one is benefit.
#' Accrual is uniform, allocation equal, and dropout independent. All time
#' quantities must share the same unit. Alpha is one-sided lower-tail error.
#' @param hazard_ratio Alternative treatment/control hazard ratio, between 0 and 1.
#' @param median_control Control exponential median survival.
#' @param accrual Duration of uniform accrual.
#' @param followup Additional follow-up after accrual ends.
#' @param dropout Probability of dropout by dropout_time in each arm.
#' @param dropout_time Reference duration for dropout probability.
#' @param alpha One-sided type I error.
#' @param power Target power.
#' @return An otd_result containing the native rpact planning object.
#' @export
#' @examples
#' if (requireNamespace("rpact", quietly = TRUE)) survival_design()
survival_design <- function(hazard_ratio = 0.7, median_control = 12,
                            accrual = 18, followup = 12, dropout = 0,
                            dropout_time = 12, alpha = 0.025, power = 0.8) {
  need("rpact"); scalar(hazard_ratio, "hazard_ratio", 0, 1)
  scalar(median_control, "median_control", 0, Inf)
  scalar(accrual, "accrual", 0, Inf); scalar(followup, "followup", 0, Inf)
  scalar(dropout_time, "dropout_time", 0, Inf)
  scalar(dropout, "dropout", -1e-15, 1)
  scalar(alpha, "alpha", 0, 0.5); scalar(power, "power", alpha, 1)
  spec <- as.list(environment()); spec <- spec[setdiff(names(spec), "spec")]
  d <- rpact::getDesignGroupSequential(kMax = 1, alpha = alpha, beta = 1-power, sided = 1)
  native <- rpact::getSampleSizeSurvival(d, typeOfComputation = "Schoenfeld",
    hazardRatio = hazard_ratio, lambda2 = log(2)/median_control,
    allocationRatioPlanned = 1, accrualTime = c(0, accrual),
    accrualIntensity = 1, accrualIntensityType = "relative", followUpTime = followup,
    dropoutRate1 = dropout, dropoutRate2 = dropout, dropoutTime = dropout_time)
  result("survival planning", list(native = native), spec, "rpact",
    "Schoenfeld exponential proportional hazards planning",
    c("one-sided benefit: treatment/control HR < 1", "equal allocation; uniform accrual",
      "independent exponential dropout; common time unit"))
}
#' Simulate survival trial operating characteristics
#'
#' simsurv generates uncensored exponential event times. Independent uniform
#' entry, exponential dropout and administrative censoring are then applied.
#' Analysis uses the two-arm logrank test from survival::survdiff. A one-sided
#' benefit p-value is obtained from its signed score, where observed minus
#' expected treatment events below zero supports benefit. An optional event
#' target stops observation at the target-th observed event calendar time; if
#' the target is not reached, analysis occurs at the administrative end and
#' the proportion reaching target is reported.
#' @param n_per_arm Integer enrollment per arm.
#' @param nsim Number of replications.
#' @param seed Integer seed.
#' @param null Simulate hazard ratio one if TRUE.
#' @param events Optional integer event target.
#' @inheritParams survival_design
#' @return An otd_result with Monte Carlo uncertainty and target attainment.
#' @export
#' @examples
#' if (requireNamespace("simsurv", quietly = TRUE))
#'   simulate_survival(50, nsim = 10, seed = 42)
simulate_survival <- function(n_per_arm, hazard_ratio = 0.7, median_control = 12,
                              accrual = 18, followup = 12, dropout = 0,
                              dropout_time = 12, alpha = 0.025, nsim = 1000,
                              seed = 1, null = FALSE, events = NULL) {
  need("simsurv"); integer_count(n_per_arm, "n_per_arm", 2)
  integer_count(nsim, "nsim", 2); integer_count(seed, "seed", 0)
  scalar(hazard_ratio, "hazard_ratio", 0, Inf)
  scalar(median_control, "median_control", 0, Inf)
  scalar(accrual, "accrual", 0, Inf); scalar(followup, "followup", 0, Inf)
  scalar(dropout, "dropout", -1e-15, 1); scalar(dropout_time, "dropout_time", 0, Inf)
  scalar(alpha, "alpha", 0, 0.5)
  if (!is.logical(null) || length(null) != 1 || is.na(null)) fail("null must be logical")
  if (!is.null(events)) {
    integer_count(events, "events", 1)
    if (events > 2*n_per_arm) fail("events exceeds enrollment")
  }
  spec <- list(n_per_arm = n_per_arm, hazard_ratio = hazard_ratio,
    median_control = median_control, accrual = accrual, followup = followup,
    dropout = dropout, dropout_time = dropout_time, alpha = alpha,
    null = null, event_target = events, estimand = "treatment/control hazard ratio")
  sims <- withr::with_seed(seed, replicate(nsim, {
    n <- 2*n_per_arm
    dat <- data.frame(id = seq_len(n), treatment = rep(0:1, each = n_per_arm))
    times <- simsurv::simsurv(dist = "exponential", lambdas = log(2)/median_control,
      x = dat, betas = c(treatment = log(if (null) 1 else hazard_ratio)),
      seed = sample.int(.Machine$integer.max, 1))
    entry <- stats::runif(n, 0, accrual)
    drop <- if (dropout == 0) rep(Inf, n) else stats::rexp(n, -log1p(-dropout)/dropout_time)
    admin <- accrual + followup
    possible <- times$eventtime <= pmin(drop, admin-entry)
    event_calendar <- sort((entry + times$eventtime)[possible])
    reached <- !is.null(events) && length(event_calendar) >= events
    end <- if (reached) event_calendar[events] else admin
    # Subjects not yet recruited at an early event stop do not enter the risk set.
    include <- entry < end
    dat$time <- pmin(times$eventtime, drop, pmax(0, end-entry))
    dat$status <- as.integer(times$eventtime <= pmin(drop, pmax(0, end-entry)))
    if (sum(dat$status) == 0 || length(unique(dat$treatment[include])) < 2) {
      p <- 1
    } else {
      fit <- survival::survdiff(survival::Surv(time, status) ~ treatment, data = dat[include, ])
      variance <- fit$var[2,2]
      z <- if (variance > 0) (fit$obs[2]-fit$exp[2])/sqrt(variance) else 0
      p <- stats::pnorm(z)
    }
    c(reject = p <= alpha, reached = reached, events = sum(dat$status), end = end)
  }))
  oc_result(sum(sims["reject", ]), nsim, spec, c("simsurv", "survival"), seed,
    if (null) "logrank equality-null type I error" else "one-sided logrank empirical power",
    list(target_attainment = if (is.null(events)) NA_real_ else mean(sims["reached", ]),
         mean_events = mean(sims["events", ]), mean_calendar_end = mean(sims["end", ])))
}
