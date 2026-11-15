test_that("normal sample sizes agree with stats and rounded power attains target", {
  s <- trial_spec(effect = 0.5)
  x <- sample_size(s)
  ref <- stats::power.t.test(delta = 0.5, sd = 1, sig.level = 0.05,
                            power = 0.8, strict = TRUE)
  expect_equal(x$data$unrounded_n_per_arm, ref$n, tolerance = 1e-8)
  expect_equal(x$data$n_per_arm, 64)
  expect_gte(x$data$achieved_power, 0.8)
  expect_lt(trial_power(s, 63)$data$power, 0.8)
})
test_that("binary directions preserve one-sided semantics", {
  s <- trial_spec("binary", effect = -0.15, p_control = 0.5, alternative = "less")
  x <- sample_size(s)
  ref <- stats::power.prop.test(p1 = 0.5, p2 = 0.35, power = 0.8,
                              alternative = "one.sided", strict = TRUE)
  expect_equal(x$data$unrounded_n_per_arm, ref$n, tolerance = 1e-8)
})
test_that("invalid and modified specifications are rejected", {
  expect_error(trial_spec(alpha = NA), class = "otd_input_error")
  expect_error(trial_spec(effect = -1, alternative = "greater"), "direction")
  expect_error(trial_spec("binary", effect = 0.9), "probability")
  expect_error(trial_power(trial_spec(), 4.2), "integer")
  s <- trial_spec(); s$alpha <- 2
  expect_error(sample_size(s), class = "otd_input_error")
})
test_that("simulations are reproducible, restore RNG and quantify uncertainty", {
  set.seed(90); before <- .Random.seed
  x <- simulate_trial(trial_spec(), 64, 200, seed = 42)
  expect_identical(.Random.seed, before)
  expect_identical(x, simulate_trial(trial_spec(), 64, 200, seed = 42))
  expect_equal(x$data$mcse, sqrt(x$data$estimate * (1-x$data$estimate)/200))
  expect_lte(x$data$lower, x$data$estimate)
  expect_gte(x$data$upper, x$data$estimate)
})
test_that("normal equality-null type I error is compatible with nominal alpha", {
  x <- simulate_trial(trial_spec(), 64, 5000, seed = 2026, null = TRUE)
  # A deterministic reference experiment with a predeclared 4-MCSE tolerance.
  expect_lt(abs(x$data$estimate - 0.05), 4 * sqrt(0.05 * 0.95 / 5000))
})
