# TD-001: Normal superiority
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Independent normal observations; common SD 1; equal allocation; two-sided alpha .05; power .8.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-001", nsim = 1000, seed = 2026)
print(result)
