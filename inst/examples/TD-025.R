# TD-025: Survival simulated power
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Exponential HR .7; uniform entry; administrative cutoff at 30; one-sided logrank alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-025", nsim = 1000, seed = 2026)
print(result)
