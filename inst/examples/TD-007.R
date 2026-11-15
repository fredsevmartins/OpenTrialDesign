# TD-007: Binary reduction
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Treatment response .35 versus control .50; lower response beneficial; one-sided alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-007", nsim = 1000, seed = 2026)
print(result)
