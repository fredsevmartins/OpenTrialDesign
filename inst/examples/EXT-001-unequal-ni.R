# Synthetic normal NI example: margin .3 is illustrative, not clinically endorsed.
library(OpenTrialDesign)
result <- means_design(effect=0,margin=.3,allocation_ratio=2)
print(result)
