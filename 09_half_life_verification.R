# 09_HALF_LIFE_VERIFICATION - Critical Fix (Mother Document)
library(deSolve)
library(ggplot2)

# Parameters from mother document (Clegg et al.)
theta <- c(
  theta <- c(
    ka = 0.286,
    CL = 0.00836,     
    Q = 0.0406,
    Vc = 0.514,
    Vp = 0.316
  )
)

# Two-compartment ODE
two_comp <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    ddepot <- -ka * depot
    dcentral <- ka * depot - (CL/Vc + Q/Vc) * central + (Q/Vp) * peripheral
    dperipheral <- (Q/Vc) * central - (Q/Vp) * peripheral
    list(c(ddepot, dcentral, dperipheral))
  })
}

state <- c(depot = 0, central = 0, peripheral = 0)
times <- seq(0, 200, by = 0.5)

# Dose 50 mg at t=0
state["depot"] <- 50
out <- ode(y = state, times = times, func = two_comp, parms = theta)
df <- as.data.frame(out)
df$cp <- df$central / theta["Vc"]

# Plot
ggplot(df, aes(x = time, y = cp)) + 
  geom_line(size = 1.2, color = "blue") +
  labs(title = "Nirsevimab Concentration-Time Profile - Half-Life Check",
       x = "Days", y = "Concentration (mg/L)") +
  theme_minimal()

# Calculate empirical terminal half-life (day 75 to 150)
cp_75  <- df$cp[which.min(abs(df$time - 75))]
cp_150 <- df$cp[which.min(abs(df$time - 150))]
t_half <- (150 - 75) * log(2) / log(cp_75 / cp_150)

cat("✅ Half-life verification completed.\n")
cat("Empirical terminal half-life (day 75–150):", round(t_half, 1), "days\n")
cat("Literature value for nirsevimab: ~71 days\n")
cat("If result is ~31 days → CL needs FcRn recycling adjustment.\n")