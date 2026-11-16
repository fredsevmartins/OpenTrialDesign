#' Execute a documented scientific example
#'
#' The version-1 product catalog is defined here. The upstream supplied no project
#' plan defining these IDs; equivalence to that external plan is not claimed.
#' See the installed examples/catalog.csv for each
#' scenario and its assumptions. Analytical and Monte Carlo outputs remain
#' distinguishable. All Monte Carlo examples accept explicit seed and nsim.
#' @param id Example ID TD-001 through TD-030.
#' @param nsim Simulation replications (where applicable).
#' @param seed Integer simulation seed.
#' @return An otd_result.
#' @export
#' @examples
#' run_example("TD-001")
run_example <- function(id, nsim = 1000, seed = 2026) {
  if (!is.character(id) || length(id) != 1 || is.na(id)) fail("id must be one TD identifier")
  integer_count(nsim, "nsim", 2); integer_count(seed, "seed", 0)
  switch(id,
    "TD-001" = sample_size(trial_spec(effect = 0.5)),
    "TD-002" = sample_size(trial_spec(effect = 0.5, alpha = 0.025, alternative = "greater")),
    "TD-003" = sample_size(trial_spec(effect = -0.5, alpha = 0.025, alternative = "less")),
    "TD-004" = sample_size(trial_spec(effect = 0.5, power = 0.9)),
    "TD-005" = trial_power(trial_spec(effect = 0.5), 64),
    "TD-006" = sample_size(trial_spec("binary", effect = 0.15, p_control = 0.3)),
    "TD-007" = sample_size(trial_spec("binary", effect = -0.15, p_control = 0.5, alpha = 0.025, alternative = "less")),
    "TD-008" = trial_power(trial_spec("binary", effect = 0.15), 180),
    "TD-009" = sequential_design(information = c(0.33, 0.67, 1)),
    "TD-010" = sequential_design(spending = "Pocock"),
    "TD-011" = sequential_design("rpact"),
    "TD-012" = sequential_design("rpact", spending = "Pocock"),
    "TD-013" = sequential_design(futility = "binding"),
    "TD-014" = sequential_design(futility = "nonbinding"),
    "TD-015" = sequential_design("rpact", futility = "nonbinding"),
    "TD-016" = conditional_power(sequential_design(), z = 1.5),
    "TD-017" = sequential_power(sequential_design(), theta = 0),
    "TD-018" = simulate_sequential(sequential_design(), nsim = nsim, seed = seed),
    "TD-019" = simulate_sequential(sequential_design(), theta = sequential_design()$data$native$delta, nsim = nsim, seed = seed),
    "TD-020" = adaptive_simulation(nsim = nsim, seed = seed),
    "TD-021" = adaptive_simulation(max_stage2 = 120, nsim = nsim, seed = seed),
    "TD-022" = survival_design(),
    "TD-023" = survival_design(dropout = 0.1),
    "TD-024" = survival_design(followup = 24),
    "TD-025" = simulate_survival(200, nsim = nsim, seed = seed),
    "TD-026" = simulate_survival(200, nsim = nsim, seed = seed, null = TRUE),
    "TD-027" = simulate_survival(200, events = 240, dropout = 0.1, nsim = nsim, seed = seed),
    "TD-028" = simulate_trial(trial_spec("binary", effect = 0.15), 180, nsim = nsim, seed = seed),
    "TD-029" = simulate_trial(trial_spec("binary", effect = 0.15), 180, nsim = nsim, seed = seed, null = TRUE),
    "TD-030" = simulate_trial(trial_spec(effect = 0.5), 64, nsim = nsim, seed = seed),
    fail("Unknown example ID; use TD-001 through TD-030"))
}
