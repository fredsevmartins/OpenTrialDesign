# TD-013: gsDesign binding futility
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Binding lower beta-spending boundary; upper alpha .025; futility must be followed.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-013", nsim = 1000, seed = 2026)
print(result)
