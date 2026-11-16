# TD-030: Normal simulated power
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Independent normal observations; common SD 1; pooled t test; two-sided alpha .05.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-030", nsim = 1000, seed = 2026)
print(result)
