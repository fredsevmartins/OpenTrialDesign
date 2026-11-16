# Synthetic crossing hazards, in common follow-up time units. Ordinary logrank
# rejection is not a constant-HR estimate or uniform survival benefit claim.
library(OpenTrialDesign)
result <- simulate_nonph(lambda_control=c(.08,.04),lambda_treatment=c(.10,.02),
  n_total=240,events=100,allocation_treatment=1,allocation_control=2,nsim=1000,seed=42)
print(result)
