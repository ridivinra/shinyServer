#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)
library(shinydashboard)
library(plotly)
library(kableExtra)
library(DT)
source("loanFun.R")
source("ui.R")
server <- function(input, output, session) { 
  
  #reset
  observeEvent(input$reset, {
    updateSelectInput(session, 'loanType')
    updateNumericInput(session, 'loanAmount', value = 30)
    updateNumericInput(session, 'timi', value = 30)
    updateNumericInput(session, 'vextir', value = 5)
    updateNumericInput(session, 'innborgun', value = 100)
  })
  
  calcLoan <- reactive({
    loanValues <- list(
      loanAmount = input$loanAmount,
      loanType = input$loanType,
      loanPayType = input$loanPayType,
      vextir = input$vextir,
      timi = input$timi,
      innborgun = input$innborgun)
    P_init <- loanValues$loanAmount*1000000
    r <- loanValues$vextir/100/12
    n <- loanValues$timi*12
    innB <- loanValues$innborgun*1000
    if(input$loanPayType == "Jafnar greiðslur"){
      res <- calcJafnarGreidslur(P_init = P_init, r = r, n = n, innborgun  = innB)
    }else{
      res <- calcJafnarAfborganir(P_init, r, n,  innborgun  = innB)
    }
    return(res)
  })
  calcLoan2 <- reactive({
    loanValues <- list(
      loanAmount = input$loanAmount2,
      loanType = input$loanType2,
      loanPayType = input$loanPayType2,
      vextir = input$vextir2,
      timi = input$timi2,
      innborgun = input$innborgun2)
  
    P_init <- loanValues$loanAmount*1000000
    r <- loanValues$vextir/100/12
    n <- loanValues$timi*12
    innB <- loanValues$innborgun*1000
    if(input$loanPayType2 == "Jafnar greiðslur"){
      res <- calcJafnarGreidslur(P_init = P_init, r = r, n = n, innborgun  = innB)
    }else{
      res <- calcJafnarAfborganir(P_init, r, n,  innborgun  = innB)
    }
    return(res)
  })
  
  pred <- reactive({
    res <- calcLoan()

    pHofudstoll <- res %>% plotHofudStoll()
    pGreidslur <- res %>% plotGreidslur()
    tblGreidslur <- res %>% 
      select(t, HofudstollEftir, greidsla, 
             vaxtaGreidsla , afborgun, innborgun) 
    info <- list(Vextir = sum(tblGreidslur$vaxtaGreidsla), Greidsla = sum(tblGreidslur$greidsla))
    return(list(
      info = info,
      lanaPlot = pHofudstoll,
      greidsluPlot = pGreidslur,
      table = datatable(tblGreidslur, 
                        colnames = c("Greiðsla nr.", "Höfuðstóll", "Greiðsla", "Vextir", "Afborgun", "Innborgun"),
                        options = list(dom = 'pt',pageLength = 12), style = "bootstrap4", rownames = F) %>% 
        formatCurrency(columns = c(2,3,4,5,6), currency = "", interval = 3, mark = ".", digits = 0)
      )
      )
  })
  
  pred2 <- reactive({
    res <- calcLoan2()
    pHofudstoll <- res %>% plotHofudStoll()
    pGreidslur <- res %>% plotGreidslur()
    tblGreidslur <- res %>% 
      select(t, HofudstollEftir, greidsla, 
             vaxtaGreidsla , afborgun, innborgun) 
    info <- list(Vextir = sum(tblGreidslur$vaxtaGreidsla), Greidsla = sum(tblGreidslur$greidsla))
    return(list(
      info = info,
      lanaPlot = pHofudstoll,
      greidsluPlot = pGreidslur,
      table = datatable(tblGreidslur, 
                        colnames = c("Greiðsla nr.", "Höfuðstóll", "Greiðsla", "Vextir", "Afborgun", "Innborgun"),
                        options = list(dom = 'pt',pageLength = 12), style = "bootstrap4", rownames = F) %>% 
        formatCurrency(columns = c(2,3,4,5,6), currency = "", interval = 3, mark = ".", digits = 0)
    )
    )
  })
  
  output$lanaPlot <- renderPlotly(pred()$lanaPlot)
  output$greidsluPlot <- renderPlotly(pred()$greidsluPlot)
  output$lanaTafla <- renderDataTable(pred()$table)
  output$greidslurVB <- renderValueBox({
    valBoxValues <- pred()$info
    valueBox(
      round(valBoxValues$Greidsla),
      "Heildargreiðslur"
    )
  })
  output$vextirVB <- renderValueBox({
    valBoxValues <- pred()$info
    valueBox(
      round(valBoxValues$Vextir),
      "Heildarvextir"
    )
  })
  
  output$lanaPlot2 <- renderPlotly(pred2()$lanaPlot)
  output$greidsluPlot2 <- renderPlotly(pred2()$greidsluPlot)
  output$lanaTafla2 <- renderDataTable(pred2()$table)
  output$greidslurVB2 <- renderValueBox({
    valBoxValues <- pred2()$info
    valueBox(
      round(valBoxValues$Greidsla),
      "Heildargreiðslur"
    )
  })
  output$vextirVB2 <- renderValueBox({
    valBoxValues <- pred2()$info
    valueBox(
      round(valBoxValues$Vextir),
      "Heildarvextir"
    )
  })
  
  output$samanburdurGreidslurPlot <- renderPlotly({
    loan1 <- calcLoan()
    loan2 <- calcLoan2()
    
    loans <- bind_rows(
      loan1 %>% mutate(tegund = "Lán 1"),
      loan2 %>% mutate(tegund = "Lán 2")
    )
    ggplotly(
      loans %>% 
        ggplot(aes(t/12, greidsla, col = tegund)) + geom_line() + theme_bw() + 
        scale_x_continuous(name = "Tími [Ár]", breaks = seq(0,max(loans$t/12),1))
    )
  })
}