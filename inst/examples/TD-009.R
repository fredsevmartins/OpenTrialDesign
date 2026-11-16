# TD-009: gsDesign OF spending
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Upper efficacy alpha .025; three information looks; no futility; canonical normal model.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-009", nsim = 1000, seed = 2026)
print(result)
