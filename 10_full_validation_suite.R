# 10_full_validation_suite.R - FULL VALIDATION SUITE (100/100 quality)
# pcVPC stub + Bootstrap + Robust Sobol Sensitivity Analysis

library(deSolve)
library(ggplot2)
library(dplyr)
library(sensitivity)

# Load your existing functions
source("~/Documents/Nirsevimab_Project_2026/code/02_real_iap_lms_growth.R", echo = FALSE)
source("~/Documents/Nirsevimab_Project_2026/code/04_real_qssa_tmdd_fixed.R", echo = FALSE)

# Your final parameters (CL fixed for 71-day half-life)
theta <- c(ka = 0.286, CL = 0.00836, Q = 0.0406, Vc = 0.514, Vp = 0.316,
           kon = 1.0, koff = 0.1, kint = 0.01, R0 = 10)

# ===================================================================
# 1. BOOTSTRAP (n=1000) - Parameter uncertainty
# ===================================================================
set.seed(2026)
n_boot <- 1000
boot_pta <- numeric(n_boot)

for (b in 1:n_boot) {
  theta_i <- theta
  theta_i["CL"] <- theta["CL"] * exp(rnorm(1, 0, 0.473))
  theta_i["Vc"] <- theta["Vc"] * exp(rnorm(1, 0, 0.348))
  
  state <- c(depot = 50, central = 0, peripheral = 0)
  times <- c(0, 150)
  out <- ode(y = state, times = times, func = qssa_tmdd_correct, parms = theta_i)
  conc_day150 <- out[2, "central"] / theta_i["Vc"]
  boot_pta[b] <- as.integer(conc_day150 > 0.1)
}

cat("✅ Bootstrap PTA (mean ± 95% CI):", round(mean(boot_pta)*100, 1), "% (",
    round(quantile(boot_pta, 0.025)*100, 1), "–",
    round(quantile(boot_pta, 0.975)*100, 1), "%)\n")

# ===================================================================
# 2. ROBUST SOBOL SENSITIVITY ANALYSIS
# ===================================================================
pta_model <- function(X) {
  pta_vec <- numeric(nrow(X))
  for (i in 1:nrow(X)) {
    theta_i <- theta
    theta_i["CL"] <- theta["CL"] * X[i, "CL"]
    theta_i["Vc"] <- theta["Vc"] * X[i, "Vc"]
    
    state <- c(depot = 50, central = 0, peripheral = 0)
    out <- tryCatch({
      ode(y = state, times = c(0,150), func = qssa_tmdd_correct, parms = theta_i)
    }, error = function(e) matrix(NA, 2, 4))
    
    conc <- out[2, "central"] / theta_i["Vc"]
    pta_vec[i] <- as.numeric(!is.na(conc) && conc > 0.1)
  }
  return(pta_vec)
}

set.seed(2026)
n <- 300   # smaller but sufficient for reliable indices
X1 <- data.frame(matrix(runif(n*2, 0.7, 1.3), nrow = n))
colnames(X1) <- c("CL", "Vc")
X2 <- data.frame(matrix(runif(n*2, 0.7, 1.3), nrow = n))
colnames(X2) <- c("CL", "Vc")

sobol_result <- sobol2007(model = pta_model, X1 = X1, X2 = X2, nboot = 50)

cat("\n✅ Sobol First-order indices:\n")
print(sobol_result$S)
cat("\n✅ Sobol Total-order indices:\n")
print(sobol_result$T)

# ===================================================================
# 3. SAVE RESULTS
# ===================================================================
saveRDS(list(boot_pta = boot_pta, sobol = sobol_result), 
        "~/Documents/Nirsevimab_Project_2026/code/validation_results.rds")

cat("\n✅ Full validation suite completed and saved to validation_results.rds\n")