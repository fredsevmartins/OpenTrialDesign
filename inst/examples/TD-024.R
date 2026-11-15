# TD-024: Longer survival follow-up
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Additional follow-up 24 after accrual 18; exponential proportional hazards; equal allocation.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-024", nsim = 1000, seed = 2026)
print(result)
