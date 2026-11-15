# TD-015: rpact nonbinding futility
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: rpact Hwang-Shih-DeCani beta spending gamma -2; nonbinding futility.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-015", nsim = 1000, seed = 2026)
print(result)
