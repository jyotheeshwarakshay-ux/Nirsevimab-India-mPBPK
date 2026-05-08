
# ================================================
# Nirsevimab Base PopPK Model - Mother Document Week 1
# India-Specific mPBPK-QSSA-TMDD Project
# ================================================

library(rxode2)
library(nlmixr2)
library(ggplot2)

# Table 1 parameters from mother document (Clegg et al. 2024)
theta <- c(
  ka   = 0.286,     # 1/day
  CL   = 0.0197,    # L/day
  Q    = 0.0406,    # L/day
  Vc   = 0.514,     # L
  Vp   = 0.316,     # L
  F    = 0.84       # bioavailability
)

# Simple two-compartment model with first-order absorption
mod <- rxode2({
  # Central compartment
  d/dt(central) = ka * depot - (CL/Vc + Q/Vc) * central + (Q/Vp) * peripheral
  # Peripheral compartment
  d/dt(peripheral) = (Q/Vc) * central - (Q/Vp) * peripheral
  # Depot (absorption)
  d/dt(depot) = -ka * depot
  # Output concentration
  cp = central / Vc
})

# Print model to confirm it loaded
print(mod)
cat("\n✅ Base nirsevimab two-compartment model loaded successfully!\n")
