test_that("probability and direction boundaries cannot silently change a design", {
  for (a in c(0, 1, Inf, NA_real_))
    expect_error(trial_spec(alpha = a), class = "otd_input_error")
  expect_error(trial_spec(effect = 0), class = "otd_input_error")
  expect_error(trial_spec(power = .05, alpha = .05), class = "otd_input_error")
  expect_error(trial_spec("binary", effect = -.3, p_control = .3), class = "otd_input_error")
  expect_error(simulate_trial(trial_spec(), 30, nsim = 1), class = "otd_input_error")
  expect_error(simulate_trial(trial_spec(), 30, seed = -1), class = "otd_input_error")
})
test_that("invalid information times and interim stages fail explicitly", {
  skip_if_not_installed("gsDesign")
  expect_error(sequential_design(information = c(.5,.5,1)), class = "otd_input_error")
  expect_error(sequential_design(information = c(.5,.9)), class = "otd_input_error")
  expect_error(conditional_power(sequential_design(), z = 1, stage = 2), class = "otd_input_error")
})
test_that("adaptive limits and survival assumptions are checked", {
  skip_if_not_installed("rpact")
  expect_error(adaptive_simulation(stage1 = 81), class = "otd_input_error")
  expect_error(adaptive_simulation(min_stage2 = 100, max_stage2 = 40), class = "otd_input_error")
  expect_error(survival_design(hazard_ratio = 1), class = "otd_input_error")
  expect_error(survival_design(dropout = 1), class = "otd_input_error")
  expect_error(survival_design(dropout = -1e-16), class = "otd_input_error")
})

test_that("survival simulation rejects negative dropout even close to zero", {
  skip_if_not_installed("simsurv")
  expect_error(simulate_survival(30, dropout = -1e-16), class = "otd_input_error")
})
