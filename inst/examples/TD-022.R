# TD-022: Survival planning
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Treatment/control HR .7; exponential control median 12; uniform accrual 18; additional follow-up 12; no dropout.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-022", nsim = 1000, seed = 2026)
print(result)
