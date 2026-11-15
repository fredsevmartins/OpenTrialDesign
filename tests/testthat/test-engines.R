test_that("gsDesign efficacy spending controls the specified one-sided alpha", {
  skip_if_not_installed("gsDesign")
  for (spend in c("OF", "Pocock")) {
    d <- sequential_design(spending = spend)
    expect_equal(sequential_power(d, 0)$data$rejection_probability, 0.025, tolerance = 1e-6)
    expect_equal(sequential_power(d)$data$rejection_probability, 0.8, tolerance = 1e-5)
    x <- simulate_sequential(d, nsim = 10000, seed = 42)
    expect_lt(abs(x$data$estimate - 0.025), 4*sqrt(0.025*0.975/10000))
    expect_equal(sum(x$data$stopping_probabilities), 1)
    expect_s3_class(conditional_power(d, 1.5), "otd_result")
  }
})
test_that("binding and nonbinding rules cannot be silently exchanged", {
  skip_if_not_installed("gsDesign")
  d <- sequential_design(futility = "binding")
  expect_error(simulate_sequential(d, enforce_futility = FALSE), "binding")
  n <- sequential_design(futility = "nonbinding")
  expect_lte(sequential_power(n, 0)$data$rejection_probability, 0.025+1e-6)
  expect_equal(simulate_sequential(n, nsim = 100, seed = 42)$data,
               simulate_sequential(n, nsim = 100, seed = 42)$data)
})
test_that("rpact adapter retains native design and matches nominal final spending", {
  skip_if_not_installed("rpact")
  for (f in c("none", "binding", "nonbinding")) {
    d <- sequential_design("rpact", futility = f)
    expect_lt(abs(tail(d$data$native$alphaSpent, 1) - 0.025), 1e-7)
    expect_equal(nrow(d$data$boundaries), 2)
  }
})
test_that("adaptive inverse-normal simulation has reproducible MC uncertainty", {
  skip_if_not_installed("rpact")
  x <- adaptive_simulation(nsim = 300, seed = 42)
  expect_equal(x$data$summary, adaptive_simulation(nsim = 300, seed = 42)$data$summary)
  expect_equal(x$data$summary$scenario, c("equality null", "alternative"))
  expect_equal(x$data$summary$estimate, x$data$summary$rejections/300)
  expect_true(all(x$data$summary$lower <= x$data$summary$estimate))
  expect_true(all(x$data$summary$upper >= x$data$summary$estimate))
})
test_that("Schoenfeld event target agrees with the independent closed form", {
  skip_if_not_installed("rpact")
  x <- survival_design()
  reference <- 4*(stats::qnorm(.975)+stats::qnorm(.8))^2/log(.7)^2
  expect_equal(as.numeric(x$data$native$eventsFixed), reference, tolerance = 1e-5)
  expect_gt(survival_design(dropout = 0.1)$data$native$nFixed, x$data$native$nFixed)
})
test_that("survival simulations are reproducible and report event target attainment", {
  skip_if_not_installed("simsurv")
  x <- simulate_survival(50, nsim = 20, seed = 42, events = 40)
  expect_identical(x$data, simulate_survival(50, nsim = 20, seed = 42, events = 40)$data)
  expect_gte(x$data$target_attainment, 0)
  expect_lte(x$data$target_attainment, 1)
  expect_lte(x$data$mean_calendar_end, 30)
  expect_error(simulate_survival(20, events = 41), "exceeds")
})
test_that("design boundaries and adaptive outputs produce plots", {
  skip_if_not_installed("gsDesign")
  expect_s3_class(plot_design(sequential_design()), "ggplot")
  expect_s3_class(plot_design(simulate_trial(trial_spec(), 30, 20)), "ggplot")
})
test_that("Monte Carlo enrollment and information summaries include uncertainty", {
  skip_if_not_installed("rpact")
  skip_if_not_installed("gsDesign")
  x <- adaptive_simulation(nsim = 100, seed = 42)
  expect_equal(x$data$summary$expected_n, as.numeric(x$data$native$expectedNumberOfSubjects), tolerance = 1e-8)
  expect_true(all(x$data$summary$expected_n_mcse >= 0))
  expect_true(all(x$data$summary$expected_n_lower <= x$data$summary$expected_n))
  d <- simulate_sequential(sequential_design(), nsim = 100, seed = 42)
  expect_equal(d$data$expected_information_uncertainty[["estimate"]], d$data$expected_information)
  expect_equal(nrow(d$data$stopping_uncertainty), 2)
})
