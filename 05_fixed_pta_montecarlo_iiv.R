# 05_FIXED_PTA_MONTECARLO_IIV - Mother Document (with IIV)
library(deSolve)
library(ggplot2)
library(dplyr)

# Reuse real IAP LMS and corrected QSSA-TMDD
# (paste the get_WT_IAP_real and qssa_tmdd_correct functions here if not already loaded)

# Parameters (half-life fixed)
theta <- c(ka = 0.286, CL = 0.00836, Q = 0.0406, Vc = 0.514, Vp = 0.316,
           kon = 1.0, koff = 0.1, kint = 0.01, R0 = 10)

# Corrected QSSA-TMDD function (from previous fix)
qssa_tmdd_correct <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    WT <- get_WT_IAP_real(t)
    CL_scaled <- CL * (WT/5)^0.75
    Vc_scaled <- Vc * (WT/5)^1.0
    Vp_scaled <- Vp * (WT/5)^1.0
    C_central <- central / Vc_scaled
    Kd_ss <- (koff + kint) / kon
    DR <- (R0 * C_central) / (Kd_ss + C_central)
    ddepot <- -ka * depot
    dcentral <- ka * depot - (CL_scaled/Vc_scaled + Q/Vc_scaled) * central + (Q/Vp_scaled) * peripheral - kint * DR * Vc_scaled
    dperipheral <- (Q/Vc_scaled) * central - (Q/Vp_scaled) * peripheral
    list(c(ddepot, dcentral, dperipheral))
  })
}

# Monte Carlo with IIV (Clegg et al. values)
set.seed(2026)
n_sim <- 500
omega_CL <- 0.473   # IIV on CL (%CV)
omega_Vc <- 0.348   # IIV on Vc (%CV)
target_conc <- 0.1   # FDA BLA protective threshold (100 ng/mL)
pta <- numeric(n_sim)

for (i in 1:n_sim) {
  theta_i <- theta
  theta_i["CL"] <- theta["CL"] * exp(rnorm(1, 0, omega_CL))
  theta_i["Vc"] <- theta["Vc"] * exp(rnorm(1, 0, omega_Vc))
  
  state <- c(depot = 0, central = 0, peripheral = 0)
  state["depot"] <- 50
  times <- c(0, 150)
  out <- ode(y = state, times = times, func = qssa_tmdd_correct, parms = theta_i)
  conc_day150 <- out[2, "central"] / theta_i["Vc"]
  pta[i] <- conc_day150 > target_conc
}

pta_percent <- mean(pta) * 100

cat("✅ Monte Carlo PTA with IIV completed (", n_sim, " Indian infants)\n")
cat("India-specific PTA =", round(pta_percent, 1), "%\n")
cat("IIV on CL and Vc now included (Clegg et al. values).\n")