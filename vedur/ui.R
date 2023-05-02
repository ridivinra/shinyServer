  library(shiny)
  library(lubridate)
  library(leaflet)
  
  # Load your data here
  load("./data/weather.RData")
  unique_datetimes <- unique(weatherDt$ftime)
  unique_dates <- unique(as.Date(weatherDt$ftime))
  
  # UI
  shinyUI(fluidPage(
    tags$style(HTML("
    .leaflet-popup-content {white-space: pre-line;}
    .irs-grid-text {
      display: none;
    }
    ")),
    titlePanel("Weather in Iceland"),
    mainPanel(
      fluidRow(
        column(12, leafletOutput("weather_map", height = "700px"))
      ),
      fluidRow(
        sliderInput("datetime_input",
                    "Select date and time:",
                    min = 1,
                    max = length(unique_datetimes),
                    value = 1,
                    step = 1,
                    sep = "",
                    animate = TRUE,
                    ticks = FALSE)
      )
    )
  ))
