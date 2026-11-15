test_that("comparison preserves scenario assumptions", {
  x <- compare_scenarios(list(small = trial_spec(effect = .3), large = trial_spec(effect = .6)))
  expect_gt(x$n_per_arm[1], x$n_per_arm[2])
  expect_identical(x$scenario, c("small", "large"))
})
test_that("diagnostics retain seed and engine", {
  x <- simulate_trial(trial_spec(), 20, 30, seed = 42)
  d <- diagnose_design(x)
  expect_equal(d$provenance$seed, 42)
  expect_equal(d$provenance$engine, "stats")
})
test_that("HTML report renders methodological provenance", {
  skip_if_not_installed("rmarkdown")
  skip_if_not(rmarkdown::pandoc_available())
  path <- tempfile() # Shiny download handlers supply an extensionless destination.
  render_report(sample_size(trial_spec()), path)
  expect_true(file.exists(path))
  html <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(html, "Methodological provenance")
  expect_match(html, "common variance")
})
test_that("Shiny server delegates calculations to shared API", {
  skip_if_not_installed("shiny")
  env <- new.env()
  sys.source(system.file("shiny/app.R", package = "OpenTrialDesign"), env)
  shiny::testServer(env$server, {
    session$setInputs(endpoint = "normal", effect = .5, sd = 1, pcontrol = .3,
      alpha = .05, power = .8, alternative = "two.sided", n = 64,
      nsim = 20, seed = 42, calculate = 1)
    expect_equal(fixed()$data$n_per_arm, 64)
    session$setInputs(null = TRUE, simulate = 1)
    active_job()$handle$process$wait(timeout=30000); harvest_job()
    expect_equal(sim()$data, simulate_trial(trial_spec(), 64, 20, 42, TRUE)$data)
  })
})
test_that("Shiny server executes sequential adaptive survival and library workflows", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("gsDesign")
  skip_if_not_installed("rpact")
  skip_if_not_installed("simsurv")
  env <- new.env()
  sys.source(system.file("shiny/app.R", package = "OpenTrialDesign"), env)
  shiny::testServer(env$server, {
    session$setInputs(endpoint = "normal", effect = .5, sd = 1, pcontrol = .3,
      alpha = .05, power = .8, alternative = "two.sided", n = 30,
      nsim = 20, seed = 42, engine = "gsDesign", spending = "OF", futility = "none",
      gsalpha = .025, sequential = 1)
    expect_equal(seq()$kind, "group sequential design")
    session$setInputs(stage1 = 80, planned = 160, min2 = 40, max2 = 240, adaptive = 1)
    active_job()$handle$process$wait(timeout=30000); harvest_job()
    expect_equal(nrow(adaptive()$data$summary), 2)
    session$setInputs(hr = .7, median = 12, accrual = 18, followup = 12, dropout = 0,
      survival = 1, survnull = TRUE, survsim = 1)
    expect_equal(surv()$kind, "survival planning")
    active_job()$handle$process$wait(timeout=30000); harvest_job()
    expect_true(survsim()$specification$null)
    session$setInputs(compare = 1)
    expect_equal(nrow(comparison()), 2)
    session$setInputs(example = "TD-001", runexample = 1)
    active_job()$handle$process$wait(timeout=30000); harvest_job()
    expect_equal(example()$data$n_per_arm, 64)
  })
})
test_that("native-only planning results display scientific output", {
  skip_if_not_installed("rpact")
  text <- paste(capture.output(print(survival_design())), collapse = "\n")
  expect_match(text, "Number of events")
  expect_match(text, "Hazard ratio")
})
