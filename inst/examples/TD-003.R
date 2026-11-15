# TD-003: Normal directional reduction
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Negative treatment-control mean; one-sided lower-tail alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-003", nsim = 1000, seed = 2026)
print(result)
