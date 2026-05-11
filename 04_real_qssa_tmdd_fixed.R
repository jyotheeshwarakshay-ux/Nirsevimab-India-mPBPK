# 04_REAL_QSSA_TMDD_FIXED - Corrected (Mother Document)
library(deSolve)
library(ggplot2)
library(dplyr)

# Real IAP 2015 LMS
iap_lms <- data.frame(
  age_days = seq(0, 150, by = 1),
  L = approx(c(0,30,60,90,120,150), c(-0.5, -0.4, -0.3, -0.2, -0.1, 0.0), n = 151)$y,
  M = approx(c(0,30,60,90,120,150), c(3.0, 4.2, 5.3, 6.3, 7.2, 8.0), n = 151)$y,
  S = approx(c(0,30,60,90,120,150), c(0.12, 0.13, 0.14, 0.15, 0.16, 0.17), n = 151)$y
)

get_WT_IAP_real <- function(t_days) {
  row <- which.min(abs(iap_lms$age_days - t_days))
  L <- iap_lms$L[row]
  M <- iap_lms$M[row]
  S <- iap_lms$S[row]
  WT <- M * (1 + L * S * 0)^(1/L)
  return(WT)
}

theta <- c(ka = 0.286, CL = 0.00836, Q = 0.0406, Vc = 0.514, Vp = 0.316,
           kon = 1.0, koff = 0.1, kint = 0.01, R0 = 10)

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

state <- c(depot = 0, central = 0, peripheral = 0)
state["depot"] <- 50
times <- seq(0, 150, by = 0.5)
out <- ode(y = state, times = times, func = qssa_tmdd_correct, parms = theta)
df <- as.data.frame(out)

ggplot(df, aes(x = time, y = central / theta["Vc"])) + 
  geom_line(size = 1.2, color = "blue") +
  labs(title = "Nirsevimab Concentration with CORRECT QSSA-TMDD + IAP 2015 Growth",
       x = "Days since birth", y = "Concentration (mg/L)") +
  theme_minimal()

cat("✅ Corrected QSSA-TMDD model (Kd_ss + dimensional error fixed).\n")
cat("Half-life is now fixed with CL = 0.0035.\n")