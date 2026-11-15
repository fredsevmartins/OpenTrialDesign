# TD-008: Binary analytical power
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: 180 per arm; treatment .45; control .30; asymptotic power.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-008", nsim = 1000, seed = 2026)
print(result)
