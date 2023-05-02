library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)

ui <- dashboardPage(
  dashboardHeader(title = "Estima"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data", tabName = "data", icon = icon("database")),
      menuItem("Analysis", tabName = "analysis", icon = icon("cogs")),
      menuItem("Results", tabName = "results", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "data",
              dataManipulationUI("data_manipulation") # Include the data manipulation module UI
      ),
      tabItem(tabName = "analysis",
              fluidRow(
                selectInput(
                  "analysis_type",
                  "Select Analysis Type:",
                  choices = c("Option 1", "Option 2", "Option 3")
                ),
                actionButton("submit", "Run Analysis")
              )
      ),
      tabItem(tabName = "results",
              fluidRow(
                tabsetPanel(
                  tabPanel("Plot", plotOutput("plot_output")),
                  tabPanel("Table", tableOutput("table_output"))
                )
              )
      )
    )
  )
)
