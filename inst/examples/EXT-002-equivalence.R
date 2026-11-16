# Synthetic asymmetric equivalence bounds; exact parallel common-variance TOST.
library(OpenTrialDesign)
result <- means_design(hypothesis="equivalence",effect=.02,lower=-.2,upper=.4,allocation_ratio=2)
print(result)
