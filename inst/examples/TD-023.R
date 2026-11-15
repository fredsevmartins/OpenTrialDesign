# TD-023: Survival dropout planning
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Independent exponential dropout with 10 percent probability by month 12; proportional hazards.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-023", nsim = 1000, seed = 2026)
print(result)
