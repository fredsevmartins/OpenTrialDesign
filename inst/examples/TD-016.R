# TD-016: Interim conditional power
# Version-1 product catalog; no external-plan equivalence claimed.
# Assumptions: Interim Z 1.5 at half information; future drift at prespecified design alternative.
# Monte Carlo runs use 1000 replications and seed 2026 by default.
library(OpenTrialDesign)
result <- run_example("TD-016", nsim = 1000, seed = 2026)
print(result)
