# ================================================
# 02_mPBPK-QSSA-TMDD Model - Mother Document Week 2-3
# India-Specific with IAP 2015 LMS Growth Ontogeny
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

# Minimal mPBPK model with QSSA-TMDD (simplified for now)
mod <- rxode2({
  # Central compartment
  d/dt(central) = ka * depot - (CL/Vc + Q/Vc) * central + (Q/Vp) * peripheral
  d/dt(peripheral) = (Q/Vc) * central - (Q/Vp) * peripheral
  d/dt(depot) = -ka * depot
  
  # Output
  cp = central / Vc
})

print(mod)
cat("\n✅ mPBPK base structure loaded!\n")
cat("Next step: Add IAP 2015 LMS growth + QSSA-TMDD + viral dynamics\n")