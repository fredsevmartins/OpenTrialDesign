library(OpenTrialDesign)
rows <- list()
record <- function(case, expected, observed, tolerance, method) {
  ok <- is.finite(observed) && abs(observed-expected) <= tolerance
  rows[[length(rows)+1L]] <<- data.frame(case = case, expected = expected,
    observed = observed, absolute_tolerance = tolerance, passed = ok, method = method)
  cat(case, "expected", expected, "observed", observed, "tolerance", tolerance, "passed", ok, "\n")
  flush.console()
}
s <- trial_spec(effect = .5)
record("normal sample size per arm", 64, sample_size(s)$data$n_per_arm, 0,
       "stats noncentral t calculation; upward rounding")
for (spending in c("OF", "Pocock")) {
  d <- sequential_design(spending = spending)
  record(paste(spending, "analytical null"), .025,
    sequential_power(d, 0)$data$rejection_probability, 1e-6, "engine numerical integration tolerance")
  record(paste(spending, "analytical alternative"), .8,
    sequential_power(d)$data$rejection_probability, 1e-5, "engine numerical integration tolerance")
}
events <- 4*(qnorm(.975)+qnorm(.8))^2/log(.7)^2
record("Schoenfeld events", events, as.numeric(survival_design()$data$native$eventsFixed),
       1e-4, "closed form versus rpact; absolute event tolerance")
B <- 5000
x <- simulate_trial(s, 64, B, 2026, TRUE)
record("normal equality null", .05, x$data$estimate, 4*sqrt(.05*.95/B),
       "Monte Carlo: prespecified four theoretical standard errors")
for (p in c(.1, .3, .5)) {
  s <- trial_spec("binary", effect = .1, p_control = p)
  x <- simulate_trial(s, 180, B, 2026, TRUE)
  record(paste("binary equality null p", p), .05, x$data$estimate,
         4*sqrt(.05*.95/B), "asymptotic score test; four-MCSE diagnostic, not exact calibration")
}
x <- adaptive_simulation(nsim = B, seed = 2026)
record("adaptive inverse normal equality null", .025, x$data$summary$estimate[1],
       4*sqrt(.025*.975/B), "native rpact procedure; four theoretical MCSE")
B <- 2000
x <- simulate_survival(200, nsim = B, seed = 2026, null = TRUE)
record("survival logrank equality null", .025, x$data$estimate,
       4*sqrt(.025*.975/B), "asymptotic signed logrank score; four theoretical MCSE")
utils::write.csv(do.call(rbind, rows), "validation/scientific-reference.csv", row.names = FALSE)
print(sessionInfo())
if (!all(vapply(rows, function(x) x$passed, logical(1)))) stop("Reference check failed")
