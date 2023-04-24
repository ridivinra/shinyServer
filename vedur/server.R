library(shiny)
library(leaflet)
library(dplyr)

# Load your data here
load("./data/weather.RData")

unique_dates <- unique(as.Date(weatherDt$ftime))
unique_times <- unique(format(weatherDt$ftime, "%H:%M"))

# Server
function(input, output, session) {
  
  # Set initial labels for date and time sliders
  observe({
    updateSliderInput(session, "date_input", label = paste("Select date:", as.character(unique_dates[input$date_input])))
    updateSliderInput(session, "time_input", label = paste("Select time:", unique_times[input$time_input + 1]))
  })
  # Update date slider label
  observeEvent(input$date_input, {
    updateSliderInput(session, "date_input", label = paste("Select date:", as.character(unique_dates[input$date_input])))
  })
  
  selected_date <- reactive({
    as.character(unique_dates[input$date_input])
  })
  
  output$time_slider <- renderUI({
    unique_times <- unique(format(weatherDt$ftime[as.Date(weatherDt$ftime) == selected_date()], "%H:%M"))
    
    sliderInput("time_input",
                "Select time:",
                min = 0,
                max = length(unique_times) - 1,
                value = 0,
                step = 1,
                sep = "",
                animate = TRUE,
                ticks = TRUE)  # Disable tick marks
  })
  
  selected_time <- reactive({
    unique_times[input$time_input+1]
  })
  
  # Update time slider label
  observeEvent(input$time_input, {
    updateSliderInput(session, "time_input", label = paste("Select time:", unique_times[input$time_input + 1]))
  })
  
  output$weather_map <- renderLeaflet({
    selected_datetime <- as.POSIXct(paste(selected_date(), selected_time()), format = "%Y-%m-%d %H:%M", tz = "UTC")
    filtered_data <- weatherDt %>%
      filter(ftime == selected_datetime)
    if (nrow(filtered_data) == 0) {
      return(NULL)
    }
    leaflet(filtered_data) %>%
      addProviderTiles(providers$CartoDB.Positron, options = providerTileOptions(attribution = "")) %>%
      setView(lng = -18.6, lat = 65.0, zoom = 6) %>%
      addCircleMarkers(
        ~long,
        ~lat,
        radius = 6,
        stroke = FALSE,
        fillOpacity = 0.9,
        popup = lapply(
          sprintf("%s<br>%s °C<br>%s m/s %s",
                  filtered_data$name,
                  filtered_data$temperature,
                  filtered_data$wind_speed,
                  filtered_data$wind_direction), 
          HTML)
      ) %>%
      addLabelOnlyMarkers(
        ~long,
        ~lat,
        label = lapply(
          sprintf("%s °C<br>%s m/s %s",
                  filtered_data$temperature,
                  filtered_data$wind_speed,
                  filtered_data$wind_direction),
          HTML),
        labelOptions = labelOptions(noHide = FALSE, direction = "auto", interactive = TRUE)
      )
    
    
  })
}
