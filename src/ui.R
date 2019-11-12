

dashboardPage(
  dashboardHeader(title = "DIMS Pipeline"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Samples", tabName = "step1", icon = icon("dashboard")),
      menuItem("Settings", tabName = "step2", icon = icon("th")),
      menuItem("Advanced Settings", tabName = "step3", icon = icon("th"))
    )),
  dashboardBody(
    singleton(tags$head(tags$script(src = "message-handler.js"))), 
    
    
    tabItems(
      # First tab content
      tabItem(tabName = "step1",
              fluidRow(
                column(12, 
                       fluidRow(column(12,
                                       fileInput("samplesheet", "1) Choose Sample Sheet ...",
                                                 multiple = FALSE,
                                                 accept = c("text/csv",
                                                            "text/comma-separated-values,text/plain",
                                                            ".csv"))
                                       
                       )),
                       p(tags$b("2) Choose folder containing .raw files ...")),
                       shinyDirButton("input_folder", "Browse...", "1) Choose raw file location..."),
                       
                       br(),
                       textOutput("test"),
                       br(), 
                       fluidRow(
                         column(8, p(tags$b("3) Select samples to be processed..."))),
                         column(4, column(3, verbatimTextOutput('count')))
                       ),
                       
                       br(),
                       fluidRow(
                         column(12, DT::dataTableOutput('table'))
                       ),
                       br(),
                       br()
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "step2",
              fluidRow( 
                column(12,
                       textInput("email", "UMC Email", config$mail),
                       textInput("login", "HPC Username", config$login),
                       numericInput("nrepl", "Technical replicates", config$nrepl),
                       selectInput("normalization", "Normalization", config$normalization),
                       numericInput("trim", "Trim", config$trim),
                       selectInput("resol", "Resolution", config$resol),
                       textInput("run_name", "Run Name", config$run_name),
                       selectInput("matrix", "Matrix", config$matrix),
                       numericInput("dims_thresh", "Threshold Min Intensity per m/z", config$dims_thresh),
                       numericInput("thresh2remove", "Threshold Min Total Intensity Count", config$thresh2remove),
                       numericInput("thresh_pos", "Threshold Min Intensity Positive Peak", config$thresh_pos),
                       numericInput("thresh_neg", "Threshold Min Intensity Negative Peak", config$thresh_neg)
                )
              ),
              fluidRow(
                column(8, p(tags$b("5) Start the pipeline..."))),
                column(4, actionButton("run", "Run", class = "btn-success"))
              )
      ),
      tabItem(tabName = "step3",
              fluidRow()
      )
    )
  )
)