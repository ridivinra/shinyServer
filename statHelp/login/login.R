# 1 - SET THE SCENE
# load required packages 
library(shiny)          # web app framework 
library(shinyjs)        # improve user experience with JavaScript
library(shinythemes)    # themes for shiny
library(tidyverse)      # data manipulation
# 2 - UI PART
# app backbone
ui <- navbarPage(
  useShinyjs(),
  title = "R Shiny advanced tips series",
  collapsible = TRUE,
  windowTitle = "R Shiny tips - TFI",
  theme = shinytheme("readable"),        
  
  tabPanel(
    title = "Demo",
    useShinyjs()    # Include shinyjs
  ),
  div(
    style = "width: 500px; max-width: 100%; margin: 0 auto;",
    id = "login-basic",
    div(
      id = "well-stuff",
      class = "well",
      h4(class = "text-center", "Please login"),
      p(class = "text-center", 
        tags$small("First approach login form")
      ),
      
      textInput(
        inputId     = "ti_user_name_basic", 
        label       = tagList(icon("user"), 
                              "User Name"),
        placeholder = "Enter user name"
      ),
      
      passwordInput(
        inputId     = "ti_password_basic", 
        label       = tagList(icon("unlock-alt"), 
                              "Password"), 
        placeholder = "Enter password"
      ), 
      
      div(
        class = "text-center",
        actionButton(
          inputId = "ab_login_button_basic", 
          label = "Log in",
          class = "btn-primary"
        )
      )
    )
  ),
  uiOutput(outputId = "display_content_basic")
  
)
# 3 - SERVER PART
server <- function(input, output, session) {
  user_base_basic_tbl <- tibble(
    user_name = "user",
    password  = "pass"
  )
  validate_password_basic <- eventReactive(input$ab_login_button_basic, {
    validate <- FALSE
    
    if (input$ti_user_name_basic == user_base_basic_tbl$user_name &&
        input$ti_password_basic == user_base_basic_tbl$password )
      {validate <- TRUE}
    return(validate)
  })
  observeEvent(validate_password_basic(), {
    print(validate_password_basic())
    print("should hide login-basic")
    shinyjs::hide(id = "well-stuff")
  })
  
  output$display_content_basic <- renderUI({
    req(validate_password_basic())
    return(h4("Access confirmed!"))
  })
}
# 4 - RUN APP
shinyApp(ui = ui, server = server)