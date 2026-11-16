# TD-011: rpact OF spending
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Engine-specific OF spending; two looks; one-sided alpha .025; no futility.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-011", nsim = 1000, seed = 2026)
print(result)
