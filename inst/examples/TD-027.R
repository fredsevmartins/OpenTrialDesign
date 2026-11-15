# TD-027: Survival event stopping
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Stop at event 240 or administrative cap 30; independent dropout; target attainment explicitly reported.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-027", nsim = 1000, seed = 2026)
print(result)
