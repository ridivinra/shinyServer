library(tidyverse)
library(shiny)
library(shinydashboard)
library(plotly)
library(kableExtra)
source("ui.R")
source("server.R")

shinyApp(ui, server)
