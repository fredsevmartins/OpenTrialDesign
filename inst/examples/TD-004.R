# TD-004: Higher target power
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Common SD 1; two-sided alpha .05; 90 percent power.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-004", nsim = 1000, seed = 2026)
print(result)
