# TD-017: Sequential analytical null
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Numerical integration under zero canonical drift; one-sided alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-017", nsim = 1000, seed = 2026)
print(result)
