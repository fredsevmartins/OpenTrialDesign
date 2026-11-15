# TD-020: Adaptive inverse normal
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Independent normal stages; fixed combination weights; native conditional-power resizing; null and alternative.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-020", nsim = 1000, seed = 2026)
print(result)
