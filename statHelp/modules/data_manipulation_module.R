# data_manipulation_module.R
library(shiny)

dataManipulationUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      fileInput(ns("file"), "Upload Dataset (CSV or Excel)",
                accept = c(".csv", ".xlsx", ".xls"))
    ),
    conditionalPanel(ns = ns,
      condition = "output.data_uploaded == true",
      box(uiOutput(ns("variable_type_selector")))
    ),
    conditionalPanel(ns = ns,
      condition = "output.data_uploaded == true",
      box(div(DT::dataTableOutput(ns("data_head")), style = "overflow-x: auto;"))
    )
  )
}


dataManipulationServer <- function(id) {
  moduleServer(id, 
    function(input, output, session) {
      HANDLEDATATYPES <- function(data,fileExt){
        print(class(data$dags))
        print(typeof(data$dags))
      }
      ASDATE <- function(column){
        if("POSIXct" %in% class(column)){
          return(as.Date(as.POSIXct(column, origin="1970-01-01")))
        }
        if(is.numeric(column)){
          if(as.Date(as.numeric(column[1]), origin = "1899-12-30") < as.Date("3000-01-01"))
            return(as.Date(as.numeric(column), origin = "1899-12-30"))
          else{
            return(as.Date(as.POSIXct(column, origin="1970-01-01")))
          }
        }
        if(is.character(column))
          return(as.Date(column))
      }
      ns <- session$ns

      # Reactive expression to store the uploaded dataset
      dataset <- reactive({
        req(input$file) # Corrected
        fileExt <- tools::file_ext(input$file$name)
        if (fileExt == "csv") {
          data <- read.csv(input$file$datapath)
        } else if (fileExt %in% c("xlsx", "xls")) {
          data <- readxl::read_excel(input$file$datapath)
        } else {
          stop("Invalid file type")
        }
        HANDLEDATATYPES(data, fileExt)
        data
      })
      
      dataset_with_updated_types <- reactive({
        req(dataset())
        data <- dataset()
        for (i in seq_along(data)) {
          input_id <- paste0("var_class_", i)
          user_selected_class <- input[[input_id]]
          if (!is.null(user_selected_class) && user_selected_class != class(data[[i]])) {
            data[[i]] <- switch(user_selected_class,
                                numeric = as.numeric(data[[i]]),
                                integer = as.integer(data[[i]]),
                                character = as.character(data[[i]]),
                                factor = as.factor(data[[i]]),
                                logical = as.logical(data[[i]]),
                                date = ASDATE(data[[i]]))
          }
        }
        data
      })
      
      output$variable_type_selector <- renderUI({
        req(dataset())
        var_names <- colnames(dataset())
        var_classes <- sapply(dataset(), class)
        
        lapply(seq_along(var_names), function(i) {
          fluidRow(
            column(4, p(var_names[i])),
            column(8,
                   selectInput(
                     inputId = ns(paste0("var_class_", i)), # Corrected
                     label = NULL,
                     choices = c("numeric", "integer", "character", "factor", "logical","date"),
                     selected = var_classes[i]
                   )
            )
          )
        })
      })
      
      # Replace renderTable with renderDataTable
      output$data_head <- DT::renderDataTable({
        req(dataset_with_updated_types())
        df_head <- head(dataset_with_updated_types())
        
        if (!is.null(input$variable_types)) {
          var_types <- input$variable_types
          for (var in var_types) {
            df_head[[var]] <- paste0("**", df_head[[var]], "**")
          }
        }
        
        datatable(df_head, options = list(dom = 't', # Only display table without other elements
                                          paging = FALSE, # Hide pagination controls
                                          searching = FALSE, # Hide search box
                                          lengthChange = FALSE),escape = FALSE) # Replace this line
      }) # Disable text sanitization to show the markdown formatting

      output$data_uploaded <- reactive({
        print(dataset())
        return(!is.null(dataset()))
      })
      outputOptions(output, "data_uploaded", suspendWhenHidden = FALSE)
      
      return(dataset)
  })
}
