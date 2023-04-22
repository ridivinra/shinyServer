library(shiny)
library(plotly)
library(lubridate)
library(tidyverse)

function(input, output, session) {
  load("./data/weather.RData")
  filtered_data <- reactiveVal()
  
  observeEvent(input$time_slider, {
    selected_time <- input$time_slider
    
    filtered_df <- weatherDt %>%
      filter(ftime == selected_time)
    
    filtered_data(filtered_df)
  })
  
  output$ice_plot <- renderPlotly({
    req(filtered_data())
    
    # Filter the data based on the selected time
    selected_data <- filtered_data()
    
    # Get Iceland's map data
    world_map <- map_data("world")
    iceland_map <- subset(world_map, region == "Iceland")
    
    # Create a plotly figure
    fig <- plot_ly() %>%
      add_polygons(
        data = iceland_map,
        x = ~long,
        y = ~lat,
        color = I("black"),
        fill = I("gray90"),
        line = list(width = 1),
        hoverinfo = "none"
      ) %>%
      layout(
        xaxis = list(
          title = "",
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE
        ),
        yaxis = list(
          title = "",
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE
        ),
        annotations = lapply(selected_data$label, function(label) {
          list(
            x = selected_data$long[label == selected_data$label],
            y = selected_data$lat[label == selected_data$label],
            xref = "x",
            yref = "y",
            text = label,
            showarrow = FALSE,
            font = list(size = 14),
            bgcolor = "white",
            opacity = 0.8,
            bordercolor = "black",
            borderwidth = 1,
            borderpad = 4
            #click = JS(sprintf("function(){Shiny.onInputChange(\'plot_clicked\', \'%s\'); Shiny.setInputValue(\'plot_clicked\', \'%s\');}", label, label))
          )
        })
      ) %>%
      config(
        displayModeBar = FALSE,
        modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d", "pan2d", "autoScale2d", "resetScale2d", "select2d", "lasso2d", "zoom3d", "resetCameraDefault3d", "resetCameraLastSave3d", "hoverClosestCartesian", "hoverCompareCartesian", "toggleSpikelines")
      )
    
    fig
  })
  
  observeEvent(input$plot_clicked, {
    # Use the input value to create a new plot
    label <- input$plot_clicked
    data <- data.frame(x = 1:10, y = rnorm(10))
    fig <- plot_ly(data, x = ~x, y = ~y, type = "scatter", mode = "lines")
    fig <- fig %>% layout(title = paste0("Weather Station: ", label))

    browser()
    output$new_plot <- renderPlotly(fig)
  })
}
