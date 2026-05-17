# 05_fixed_pta_montecarlo_iiv.R - FULLY FIXED: Z-score active + 50/100 mg weight-banded dosing
library(deSolve)
source("02_real_iap_lms_growth.R")
source("04_real_qssa_tmdd_fixed.R")

theta <- c(ka = 0.286, CL = 0.00836, Q = 0.0406, Vc = 0.514, Vp = 0.316,
           kon = 1.0, koff = 0.1, kint = 0.01, R0 = 10)

set.seed(2026)
n_sim <- 500
omega_CL <- 0.473
omega_Vc <- 0.348
target_conc <- 0.1
pta <- numeric(n_sim)
conc_day150_all <- numeric(n_sim)

for (i in 1:n_sim) {
  theta_i <- theta
  Z_i <- rnorm(1, 0, 1)
  theta_i["CL"] <- theta["CL"] * exp(rnorm(1, 0, omega_CL))
  theta_i["Vc"] <- theta["Vc"] * exp(rnorm(1, 0, omega_Vc))
  theta_i["Z"]  <- Z_i
  
  # FDA weight-banded dosing (50 mg if birth weight <5 kg, 100 mg otherwise)
  WT_birth <- get_WT_IAP_real(0, Z = Z_i)
  dose_i   <- ifelse(WT_birth < 5, 50, 100)
  
  state <- c(depot = dose_i, central = 0, peripheral = 0)
  times <- c(0, 150)
  out <- ode(y = state, times = times, func = qssa_tmdd_correct, parms = theta_i)
  
  WT_150 <- get_WT_IAP_real(150, Z = Z_i)
  Vc_150 <- theta_i["Vc"] * (WT_150 / 5)^1.0
  conc_day150_all[i] <- out[2, "central"] / Vc_150
  pta[i] <- conc_day150_all[i] > target_conc
}

pta_percent <- mean(pta) * 100
cat("✅ Monte Carlo with Z-score + 50/100 mg weight-banded dosing completed\n")
cat("India-specific PTA =", round(pta_percent, 1), "%\n")
cat("Number of virtual infants protected =", sum(pta), "out of", n_sim, "\n")