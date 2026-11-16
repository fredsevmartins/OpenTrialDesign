# Exact conditional Fisher simulation is distinct from approximate sample sizing.
library(OpenTrialDesign)
spec <- trial_spec("binary",effect=.005,p_control=.01)
print(binary_diagnostics(spec,10,TRUE))
result <- simulate_trial(spec,10,nsim=1000,seed=42,null=TRUE,binary_test="fisher")
print(result)
