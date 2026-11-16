# TD-029: Binary equality null
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Both response probabilities .30; two-sided uncorrected score test; empirical equality-null error.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-029", nsim = 1000, seed = 2026)
print(result)
