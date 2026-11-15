# TD-014: gsDesign nonbinding futility
# PROVISIONAL catalog; original project plan unavailable.
# Assumptions: Upper alpha control ignores lower futility; actual power assumes lower stopping.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-014", nsim = 1000, seed = 2026)
print(result)
