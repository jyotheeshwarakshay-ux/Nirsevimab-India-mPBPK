# 08_shiny_dosing_simulator_real.R - FINAL CLEAN VERSION (Mother Document Compliant)
library(shiny)
library(ggplot2)
library(deSolve)

# Load required functions
source("~/Documents/Nirsevimab_Project_2026/code/02_real_iap_lms_growth.R", echo = FALSE)
source("~/Documents/Nirsevimab_Project_2026/code/04_real_qssa_tmdd_fixed.R", echo = FALSE)

# Parameters (CL fixed for 71-day half-life)
theta <- c(ka = 0.286, CL = 0.00836, Q = 0.0406, Vc = 0.514, Vp = 0.316,
           kon = 1.0, koff = 0.1, kint = 0.01, R0 = 10)

# UI
ui <- fluidPage(
  titlePanel("India-Specific Nirsevimab Dosing Simulator (Real IAP 2015 + Correct QSSA-TMDD)"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("days", "Days since birth (RSV season)", min = 0, max = 150, value = 48, step = 1),
      numericInput("dose", "Dose (mg)", value = 50, min = 0, step = 1),
      actionButton("run", "Run Simulation", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("conc_plot", height = "400px"),
      verbatimTextOutput("result")
    )
  )
)

# Server
server <- function(input, output) {
  sim <- eventReactive(input$run, {
    state <- c(depot = 0, central = 0, peripheral = 0)
    state["depot"] <- input$dose
    times <- seq(0, 150, by = 0.5)
    out <- ode(y = state, times = times, func = qssa_tmdd_correct, parms = theta)
    df <- as.data.frame(out)
    df$conc <- df$central / (theta["Vc"] * (get_WT_IAP_real(df$time) / 5)^1.0)
    list(time = df$time, conc = df$conc)
  })
  
  output$conc_plot <- renderPlot({
    s <- sim()
    ggplot(data.frame(time = s$time, conc = s$conc), aes(x = time, y = conc)) +
      geom_line(color = "blue", size = 1.2) +
      geom_vline(xintercept = input$days, linetype = "dashed", color = "red", size = 1) +
      labs(title = paste("Concentration at day", input$days, "=", round(s$conc[which.min(abs(s$time - input$days))], 3), "mg/L"),
           x = "Days since birth", y = "Serum Concentration (mg/L)") +
      theme_minimal(base_size = 14)
  })
  
  output$result <- renderPrint({
    s <- sim()
    conc_day <- s$conc[which.min(abs(s$time - input$days))]
    pta <- conc_day > 0.1
    cat("Concentration at day", input$days, ":", round(conc_day, 3), "mg/L\n")
    cat("Target Attainment (PTA):", ifelse(pta, "YES (protected)", "NO (risk of breakthrough)"), "\n")
    cat("Corrected model with real IAP 2015 LMS + QSSA-TMDD (mother document compliant).\n")
  })
}

shinyApp(ui, server)