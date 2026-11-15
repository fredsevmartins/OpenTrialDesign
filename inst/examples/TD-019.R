# TD-019: Sequential Monte Carlo power
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Canonical drift from native design alternative; prespecified information times.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-019", nsim = 1000, seed = 2026)
print(result)
