# ================================================
# 08_Shiny Dosing Simulator - Mother Document Final Output
# Interactive India-Specific Nirsevimab mPBPK Tool
# ================================================

library(shiny)
library(ggplot2)
library(dplyr)

# IAP 2015 growth function
get_WT_IAP <- function(t_days) {
  WT <- 3.0 + 0.025 * t_days + 0.00008 * t_days^2
  WT <- pmax(WT, 3.0)
  return(WT)
}

ui <- fluidPage(
  titlePanel("India-Specific Nirsevimab Dosing Simulator (IAP 2015 + mPBPK)"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("days", "Days since birth (RSV season)", 0, 150, 75),
      numericInput("weight", "Current weight (kg)", 5, min = 2, max = 15, step = 0.1),
      selectInput("dose_band", "Dosing regimen", choices = c("50 mg (<5kg)", "100 mg (≥5kg)"), selected = "100 mg (≥5kg)"),
      actionButton("simulate", "Run Simulation")
    ),
    mainPanel(
      plotOutput("pta_plot"),
      verbatimTextOutput("result")
    )
  )
)

server <- function(input, output) {
  sim <- eventReactive(input$simulate, {
    WT <- input$weight
    dose <- ifelse(WT < 5, 50, 100)
    CL_scaled <- 0.0197 * (WT/5)^0.75
    Vc_scaled <- 0.514 * (WT/5)^1.0
    conc <- (dose * 0.84 / Vc_scaled) * exp(-CL_scaled / Vc_scaled * input$days)
    list(conc = conc, pta = conc > 0.5)
  })
  
  output$pta_plot <- renderPlot({
    s <- sim()
    ggplot(data.frame(x = 0:150, y = get_WT_IAP(0:150)), aes(x, y)) +
      geom_line(color = "blue", size = 1.2) +
      geom_vline(xintercept = input$days, linetype = "dashed") +
      labs(title = paste("Concentration at day", input$days, "=", round(s$conc, 3), "mg/L"),
           x = "Days since birth", y = "Body Weight (kg)") +
      theme_minimal()
  })
  
  output$result <- renderPrint({
    s <- sim()
    cat("Concentration at day", input$days, ":", round(s$conc, 3), "mg/L\n")
    cat("Target Attainment (PTA):", ifelse(s$pta, "YES (protected)", "NO (risk of breakthrough)"), "\n")
    cat("This is the interactive tool described in the mother document.\n")
  })
}

shinyApp(ui, server)