# TD-021: Adaptive capped enrollment
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Stage-two total enrollment limited to 40--120; fixed inverse-normal weights; both hypotheses simulated.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-021", nsim = 1000, seed = 2026)
print(result)
