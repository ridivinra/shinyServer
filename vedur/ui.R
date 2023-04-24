library(shiny)
library(lubridate)

# Load your data here
load("./data/weather.RData")

unique_dates <- unique(as.Date(weatherDt$ftime))

# UI
shinyUI(fluidPage(
  tags$style(HTML("
  .irs-grid-text {
    display: none;
  }
  ")),
  titlePanel("Weather in Iceland"),
  mainPanel(
    fluidRow(
      column(12, leafletOutput("weather_map", height = 600))
    ),
    fluidRow(
      column(6,
             sliderInput("date_input",
                         "Select date:",
                         min = 1,
                         max = length(unique_dates),
                         value = 1,
                         step = 1,
                         sep = "",
                         animate = TRUE,
                         ticks = FALSE)),  # Disable tick marks
      column(6,
             uiOutput("time_slider"))
    )
  )
))
