# TD-012: rpact Pocock spending
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: rpact asP spending; two looks; no futility.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-012", nsim = 1000, seed = 2026)
print(result)
