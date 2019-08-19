library("shinythemes")

fluidPage(
  theme = shinytheme("paper"),
  singleton(tags$head(tags$script(src = "message-handler.js"))), 
  #shinythemes::themeSelector(), 
  
  fluidRow(
    column(6, # left 
           titlePanel("DIMS pipeline"),
           
           br(), br(),
           fluidRow(
             column(8, p(tags$b("1) Choose raw file location..."))),
             column(4, shinyDirButton("raw_file_location", "Browse...", "1) Choose raw file location..."))
           ),
           
           br(), 
           fluidRow(
             column(8, p(tags$b("2) Upload experimental design..."))),
             column(4, shinyFilesButton("experimental_design", "Browse...", "2) Upload experimental design...", multiple=FALSE))
           ),
           
           br(),
           p(tags$b("4) Select parameters...")),
           
           fluidRow(
             column(6,  
                    textInput("email", "UMC Email", config$mail),
                    numericInput("nrepl", "Technical replicates", config$nrepl),
                    selectInput("normalization", "Normalization", config$normalization),
                    numericInput("trim", "Trim", config$trim),
                    numericInput("resol", "Resolution", config$resol)
             ),
             column(6,
                    textInput("run_name", "Run Name", config$run_name),
                    #selectInput("data_type", "Data Type", config$data_type),
                    #selectInput("thresh2remove", "Threshold to remove", list("1e+09 (plasma)", "5e+08 (blood spots)", "1e+08 (research (Mia))")),
                    numericInput("thresh2remove", "Min Intensity Sum", config$thresh2remove),
                    numericInput("dims_thresh", "Min Intensity Threshold", config$dims_thresh),
                    numericInput("thresh_pos", "Max Intensity Positive Threshold", config$thresh_pos),
                    numericInput("thresh_neg", "Max Intensity Negative Threshold", config$thresh_neg)
             )
           ),
           fluidRow(
             column(8, p(tags$b("5) Start the pipeline..."))),
             column(4, actionButton("run", "Run", class = "btn-success")))
    ),
    column(6, # right
           br(),
           wellPanel(style = "overflow-y:scroll; max-height: 700px",
                     useShinyjs(),
                     fluidPage(
                       br(),   
                       fluidRow(
                         column(8, p(tags$b("3) Select samples to be processed..."))),
                         column(4, actionButton("check_all", "Select All"))
                       ),
                       
                       br(),
                       fluidRow(
                         column(4, checkboxGroupInput("inCheckboxGroup", tags$b("Sample Name"))),
                         column(8, tags$b("File Name"), br(), tableOutput("contents"))
                       )
                     )
           )
    )
  )
)