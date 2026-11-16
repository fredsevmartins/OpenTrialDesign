# TD-005: Normal power at enrollment
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: 64 independent participants per arm; pooled two-sample t test.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-005", nsim = 1000, seed = 2026)
print(result)
