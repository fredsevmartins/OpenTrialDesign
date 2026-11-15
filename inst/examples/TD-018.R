# TD-018: Sequential Monte Carlo null
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Independent canonical normal increments; zero drift; exact Monte Carlo interval.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-018", nsim = 1000, seed = 2026)
print(result)
