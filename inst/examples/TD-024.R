# TD-024: Longer survival follow-up
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Additional follow-up 24 after accrual 18; exponential proportional hazards; equal allocation.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-024", nsim = 1000, seed = 2026)
print(result)
