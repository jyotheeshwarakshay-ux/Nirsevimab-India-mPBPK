# ================================================
# 03_IAP_Growth_Ontogeny - Mother Document
# India-Specific mPBPK with IAP 2015 LMS scaling
# ================================================

library(rxode2)
library(nlmixr2)
library(ggplot2)
library(dplyr)

# Base parameters from mother document Table 1
theta <- c(
  ka   = 0.286,    
  CL   = 0.0197,   
  Q    = 0.0406,   
  Vc   = 0.514,    
  Vp   = 0.316,    
  F    = 0.84      
)

# Simple allometric scaling with IAP 2015 growth (mother document requirement)
# For now we use body weight scaling (full LMS integration in next step)
mod <- rxode2({
  # Allometric scaling with body weight (IAP 2015 will be added dynamically)
  CL_scaled = CL * (WT/5)^0.75
  Vc_scaled = Vc * (WT/5)^1.0
  
  # Central compartment
  d/dt(central) = ka * depot - (CL_scaled/Vc_scaled + Q/Vc_scaled) * central + (Q/Vp) * peripheral
  d/dt(peripheral) = (Q/Vc_scaled) * central - (Q/Vp) * peripheral
  d/dt(depot) = -ka * depot
  
  cp = central / Vc_scaled
})

print(mod)
cat("\n✅ IAP growth ontogeny base structure loaded (allometric scaling)!\n")
cat("Next step tomorrow: Full LMS hard-coding + QSSA-TMDD + viral dynamics\n")