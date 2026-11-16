# TD-028: Binary simulated power
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Uncorrected Pearson score test; .30 control and .45 treatment; finite-sample power may differ from planning.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-028", nsim = 1000, seed = 2026)
print(result)
