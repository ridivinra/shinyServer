library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readxl)
library(DT)
source("modules/data_manipulation_module.R")

server <- function(input, output) {
  
  dataset <- dataManipulationServer("data_manipulation")
  # Run the analysis and generate plot and table
  observeEvent(input$submit, {
    # Placeholder code for running the selected analysis on the uploaded dataset
    # You will need to replace this with your actual analysis logic
    output$plot_output <- renderPlot({
      req(dataset())
      hist(dataset()[[1]]) # Basic histogram example, replace with actual plot
    })
    
    output$table_output <- renderTable({
      req(dataset())
      dataset()[1:10, ] # Display the first 10 rows of the dataset as an example
    })
  })
}

