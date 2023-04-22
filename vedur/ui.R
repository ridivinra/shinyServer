library(shiny)
library(shinyWidgets)
library(plotly)
library(lubridate)
library(htmlwidgets)
library(tidyverse)

load("./data/weather.RData")
unique_time_points <- unique(weatherDt$ftime)
time_labels <- setNames(as.character(unique_time_points), as.character(unique_time_points))

ui <- fluidPage(
  tags$head(
    tags$style(
      HTML("
      .center_plot {
        display: flex;
        justify-content: center;
        align-items: center;
      }
    ")
    ),
    tags$script(
      HTML("
      function setPlotHeight() {
        var plotWrapper = document.getElementById('ice_plot');
        var plotElement = plotWrapper.querySelector('.shiny-plot-output');
        var aspectRatio = 0.6; // Replace with your desired aspect ratio
        plotElement.style.height = (plotWrapper.offsetWidth * aspectRatio) + 'px';
      }

      // Set plot height on initial load
      document.addEventListener('DOMContentLoaded', setPlotHeight);

      // Update plot height on window resize
      window.addEventListener('resize', setPlotHeight);
    ")
    )
  ),
  titlePanel("Weather Data in Iceland"),
  fluidRow(
    div(
      id = "ice_plot",
      plotlyOutput("ice_plot", width = "80%", height = "500")
    )
  ),
  fluidRow(plotlyOutput("new_plot")),
  fluidRow(
    div(
      class = "center_plot",
      sliderTextInput(
        inputId = "time_slider",
        label = "Select time:",
        choices = time_labels,
        selected = time_labels[[1]],
        animate = animationOptions(interval = 250, loop = FALSE),
        width = "80%"
      )
    )
  )
)
