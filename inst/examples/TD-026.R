# TD-026: Survival equality null
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: HR 1 equality null; independent censoring; one-sided lower-tail logrank test.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-026", nsim = 1000, seed = 2026)
print(result)
