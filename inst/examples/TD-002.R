# TD-002: Normal directional benefit
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Positive treatment-control mean; one-sided alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-002", nsim = 1000, seed = 2026)
print(result)
