# TD-010: gsDesign Pocock spending
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Two looks at .5 and 1; Lan-DeMets Pocock spending; upper efficacy alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-010", nsim = 1000, seed = 2026)
print(result)
