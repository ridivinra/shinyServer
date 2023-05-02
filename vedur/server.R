library(shiny)
library(leaflet)
library(dplyr)
library(leaflet.extras)
library(htmltools)

# Load your data here
load("./data/weather.RData")
unique_datetimes <- unique(weatherDt$ftime)
wind_direction_to_arrow <- function(wind_direction) {
  wind_codes <- c("N", "NNV", "NV", "VNV", "V", "VSV", "SV", "SSV", "S", "SSA", "SA", "ASA", "A", "ANA", "NA", "NNA", "Logn")
  arrows <- c("↑", "↖", "↖", "↖", "←", "↙", "↙", "↙", "↓", "↘", "↘", "↘", "→", "↗", "↗", "↗", "─")
  return(arrows[match(wind_direction, wind_codes)])
}

# Server
shinyServer(function(input, output, session) {
  selected_datetime <- reactive({
    unique_datetimes[input$datetime_input]
  })
  
  observe({
    updateSliderInput(session, "datetime_input", label = paste("Select date and time:", format(selected_datetime(), "%Y-%m-%d %H:%M")))
  })
  
  observeEvent(input$datetime_input, {
    updateSliderInput(session, "datetime_input", label = paste("Select date and time:", format(selected_datetime(), "%Y-%m-%d %H:%M")))
  })
  
  
  output$weather_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -18.6, lat = 65.0, zoom = 6.3)
  })
  
  
  observeEvent(input$datetime_input, {
    selected_datetime <- unique_datetimes[input$datetime_input]
    filtered_data <- weatherDt %>%
      filter(ftime == selected_datetime)
    
    leafletProxy("weather_map") %>%
      clearMarkers() %>%
      addLabelOnlyMarkers(data = filtered_data,
                          lng = ~long, lat = ~lat,
                          label = ~paste0("<b>", wind_direction_to_arrow(wind_direction), "</b><br>",
                                          temperature, "°C<br>", wind_speed, "m/s"),
                          labelOptions = labelOptions(noHide = TRUE, direction = "auto", offset = c(0, 20)))
  })
  
  
  
  
  
})
