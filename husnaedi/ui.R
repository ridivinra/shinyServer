library(shiny)
library(shinydashboard)
library(plotly)
library(DT)

header <- dashboardHeader(title = "Lánareiknivél")

sidebar <- dashboardSidebar(sidebarMenu(
  menuItem(
    "Lán 1",
    tabName = "model1",
    icon = icon("bar-chart-o")
  ),
  menuItem(
    "Lán 2",
    tabName = "model2",
    icon = icon("bar-chart-o")
  ),
  menuItem(
    "Samanburður",
    tabName = "samanburdur",
    icon = icon("bar-chart-o")
  )
))

body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "model1",
      h1("Lán 1"),
      fluidRow(box(
        width = 12,
        fluidRow(
          column(4,
               numericInput("loanAmount",
                            "Höfuðstóll [m.ISK]",
                            40)),
        column(4,
               selectInput(
                 "loanType",
                 "Óverðtryggt eða verðtryggt lán",
                 c("Óverðtryggt", "Verðtryggt")
               )),
        column(4,
               selectInput(
                 "loanPayType",
                 "Afborganir",
                 c("Jafnar greiðslur", "Jafnar afborganir")
               ) )
      ),
      fluidRow(
        column(4,
               numericInput("vextir",
                            "Vextir [%]",
                            5)),
        column(4,
               numericInput("timi",
                            "Tími láns [ár]",
                            20)),
        column(
          4,
          numericInput("innborgun",
                       "Mánaðarleg innborgun [þ.ISK]",
                       0)
        )
      )
    )),
    valueBoxOutput("greidslurVB", width = 6),valueBoxOutput("vextirVB", width = 6),
    fluidRow(box(
      width = 6,
      tabsetPanel(
        tabPanel(title = "Þróun höfuðstóls",plotly::plotlyOutput("lanaPlot")),
        tabPanel(title = "Þróun greiðslna",plotly::plotlyOutput("greidsluPlot"))
      )
    ),
    box(width = 6, dataTableOutput("lanaTafla"))),
    fluidRow(uiOutput("boxes"))
    ),
    tabItem(
      tabName = "model2",
      h1("Lán 2"),
      fluidRow(box(
        width = 12,
        fluidRow(
          column(4,
                 numericInput("loanAmount2",
                              "Höfuðstóll [m.ISK]",
                              40)),
          column(4,
                 selectInput(
                   "loanType2",
                   "Óverðtryggt eða verðtryggt lán",
                   c("Óverðtryggt", "Verðtryggt")
                 )),
          column(4,
                 selectInput(
                   "loanPayType2",
                   "Afborganir",
                   c("Jafnar greiðslur", "Jafnar afborganir"),selected = "Jafnar afborganir"
                 ), )
        ),
        fluidRow(
          column(4,
                 numericInput("vextir2",
                              "Vextir [%]",
                              5)),
          column(4,
                 numericInput("timi2",
                              "Tími láns [ár]",
                              20)),
          column(
            4,
            numericInput("innborgun2",
                         "Mánaðarleg innborgun [þ.ISK]",
                         0)
          )
        )
      )),
      valueBoxOutput("greidslurVB2", width = 6),valueBoxOutput("vextirVB2", width = 6),
      fluidRow(box(
        width = 6,
        tabsetPanel(
          tabPanel(title = "Þróun höfuðstóls",plotly::plotlyOutput("lanaPlot2")),
          tabPanel(title = "Þróun greiðslna",plotly::plotlyOutput("greidsluPlot2"))
        )
      ),
      box(width = 6, dataTableOutput("lanaTafla2")))
    ),
    tabItem(
      tabName = "samanburdur",
      h1("Samanburður"),
      fluidRow(
        box(
          width = 6, 
          h2("Greiðslur"),
          plotly::plotlyOutput("samanburdurGreidslurPlot")
        )
      )
      )
),

)

ui <- dashboardPage(header,
                    sidebar,
                    body)
