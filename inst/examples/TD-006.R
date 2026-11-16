# TD-006: Binary superiority
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Response probabilities .30 versus .45; normal approximation; no continuity correction.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-006", nsim = 1000, seed = 2026)
print(result)
