# TD-017: Sequential analytical null
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Numerical integration under zero canonical drift; one-sided alpha .025.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-017", nsim = 1000, seed = 2026)
print(result)
