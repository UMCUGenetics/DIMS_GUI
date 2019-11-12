function(input, output, session) {
  shinyDirChoose(input, "input_folder", roots = c(home = config$root), filetypes=c('raw'))
  path1 <- reactive({
    return(print(parseDirPath(volumes, input$input_folder)))
  })
  
  observe({  
    ### Start Select Sample Sheet
    datasetInput <- reactive({
      # input$samplesheet will be NULL initially. After the user selects
      # and uploads a file, it will be a data frame with 'name',
      # 'size', 'type', and 'datapath' columns. The 'datapath'
      # column will contain the local filenames where the data can be found.
      inFile <- input$samplesheet
      if (is.null(inFile))
        return(NULL)
      read.csv(inFile$datapath, 
               header = TRUE,
               sep = "\t",
               quote = "")
    })
    
    df <- datasetInput()
    if (!is.null(df)) df$File_Found = FALSE
    
    output$table = DT::renderDataTable(df, 
                                       server = TRUE,
                                       selection = list(mode = 'multiple', 
                                                        selected = rownames(df)))
    ### End Select Sample Sheet
    
    
    ### Start Select Input Folder
    observeEvent(input$input_folder, {
      input_folder_name <- paste(as.vector(unlist(input$input_folder['path']))[-1], collapse = "/", sep="")
      if (input_folder_name != '') {
        if (!is.null(df)) {
          ### Set Run Name parameter
          updateTextInput(session, "run_name", value = gsub(" ", "_", input_folder_name))
          
          ### Check files with sample sheet
          files <- list.files(path = paste(config$root, input_folder_name, sep="/"), pattern = ".raw$")
          files <- gsub(files, pattern=".raw$", replacement="")
          df$File_Found <- df[,1] %in% files
          
          ### Update table based on which files from the sample sheet were in the selected folder
          output$table = DT::renderDataTable(df, 
                                             server = TRUE,
                                             selection = list(mode = 'multiple', 
                                                              selected = input$table_rows_selected))
        }
      }
    })
    ### End Select Input Folder
    
    #text <- paste(length(which(df$File_Found == FALSE)), "out of the", length(input$table_rows_selected), "selected .raw files were not found in the selected directory.")
    #output$test <- renderText(text)
    
    ### Start run
    observeEvent(input$run, {
      ### Check if there is input
      if (is.na(input$input_folder['path'])) {
        session$sendCustomMessage(type = "testmessage", message = "Choose a file location!")
      } else if (is.na(input$samplesheet['files'])) {
        session$sendCustomMessage(type = "testmessage", message = "Choose an experimental design!")
      } else if (input$email == '') {
        session$sendCustomMessage(type = "testmessage", message = "Enter your email!")
      } else if (input$run_name == '') {
        session$sendCustomMessage(type = "testmessage", message = "Enter a name for the run!")
      } else {
        
        ### Create all the paths 
        hpcInputDir = paste(config$base, "raw_data", input$run_name, sep="/")
        hpcOutputDir = paste(config$base, "processed", input$run_name, sep="/")
        hpcLogDir = paste(config$base, "processed", input$run_name, "logs", "queue", sep="/")
        
        ### Check samples with design
        samplesDesign = paste(as.vector(unlist(df[input$inCheckboxGroup, 1])), "raw", sep=".")
        raw = list.files(path = paste(config$root, inputDirName, sep="/"), pattern = "raw")
        index = which(samplesDesign %in% raw)
        
        
        if (length(samplesDesign) != length(index)) {
          session$sendCustomMessage(type = "testmessage",
                                    message = "Design and mzXML files differ!")
        } else {
          
          ### Make init.RData (repl.pattern)
          sampleNames=trimws(as.vector(unlist(df[,1])))
          nsampgrps = length(sampleNames)/input$nrepl # number of individual biological samples
          groupNames=trimws(as.vector(unlist(df[,2])))
          groupNamesUnique=unique(groupNames)
          wrongTechRepCount = FALSE
          for (x in groupNamesUnique) {
            if (sum(groupNames == x) != input$nrepl) {
              wrongTechRepCount = TRUE
            }
          }
          if (length(groupNamesUnique) != nsampgrps) {
            session$sendCustomMessage(
              type = "testmessage",
              message = paste("Expected", nsampgrps, "unique biological samples, but only found", length(groupNamesUnique))
            )
          } else if (wrongTechRepCount) {
            session$sendCustomMessage(
              type = "testmessage",
              message = paste("Not every sample has",input$nrepl,"technical replicates")
            )
          } else {
            repl.pattern = c()
            for (a in 1:nsampgrps) {
              tmp = c()
              for (b in input$nrepl:1) {
                i = ((a*input$nrepl)-b)+1
                tmp <- c(tmp, sampleNames[i])
              }
              repl.pattern <- c(repl.pattern, list(tmp))
            }
            
            names(repl.pattern) = groupNamesUnique
            
            ### Save sample sheet
            write.table(df[input$inCheckboxGroup,], file=paste(tmpDir, "sampleNames_out.txt", sep="/"), quote = FALSE, sep="\t",row.names = FALSE)
            files=paste(config$root, inputDirName, paste(as.vector(unlist(df[input$inCheckboxGroup, 1])),"raw", sep="."), sep="/")
            
            output$samples = renderTable({ as.data.frame(files) })
            
            selectedSamples = df[input$inCheckboxGroup,]
            save(selectedSamples, file=paste(tmpDir, "selectedSamples.RData", sep="/"))
            remove = which(sampleNames %in% selectedSamples$File_Name)
            rval = NULL
            if (length(remove)>0) rval = functions$removeFromRepl.pat(sampleNames[-remove], repl.pattern, groupNamesUnique, input$nrepl)
            
            repl.pattern=rval$pattern
            save(repl.pattern, file=paste(tmpDir, "init.RData", sep="/"))
            
            ### Create settings.config
            fileConn = file(paste(tmpDir, "settings.config", sep = "/"))
            parameters <- c(
              paste("# Created by", config$commit, "on", format(Sys.time(), "%b %d %Y %X")),
              paste0("thresh_pos=", input$thresh_pos),
              paste0("thresh_neg=", input$thresh_neg),
              paste0("dims_thresh=", input$dims_thresh),
              paste0("trim=", input$trim),
              paste0("nrepl=", input$nrepl),
              paste0("normalization=", input$normalization),
              paste0("thresh2remove=", input$thresh2remove),
              paste0("resol=", input$resol),
              paste0("email=", input$email),
              paste0("matrix=", config$matrix),
              paste0("proteowizard=", config$proteowizard),
              paste0("db=", config$db),
              paste0("db2=", config$db2),
              paste0("z_score=", config$z_score)
            )
            
            writeLines(parameters, fileConn, sep = "\n")
            close(fileConn)
            
            
            ### Connect to HPC
            if (exists("ssh_key")) {
              ssh = ssh_connect(config$ssh_host, config$ssh_key)
            } else {
              ssh = ssh_connect(config$ssh_host)
            }
            print(ssh)
            
            ### Create directory on HPC
            #fail <- 1
            fail <- ssh_exec_wait(ssh, paste0("mkdir ", hpcInputDir))
            if (fail == 1) {
              session$sendCustomMessage(type = "testmessage",
                                        message = "A directory with this name already exists on HPC!")
            } else {
              ### Copy over RAW data
              inputDir = paste(config$root, inputDirName, sep="/")
              message(paste0("Uploading files from ",inputDir ," to: ", hpcInputDir, " (ignore the %)"))
              for (s in samplesDesign) {
                scp_upload(ssh, paste(inputDir, s, sep="/"), to = hpcInputDir)
              }
              
              ### Copy over the tmp files (eg. init.RData, settings.config)
              message(paste("Uploading files from", tmpDir, "to:", hpcInputDir))
              scp_upload(ssh, list.files(tmpDir, full.names = TRUE), to = hpcInputDir)
              
              if (config$run_pipeline) {
                ### Start the pipeline
                cmd = paste("cd", config$scriptDir, "&& sh run.sh -i", hpcInputDir, "-o", hpcOutputDir)
                message(paste("Starting the pipeline with:", cmd))
                ssh_exec_wait(ssh, cmd, std_out = "0-queueConversion", std_err="0-queueConversion")
                
                ### Copy over the log file that was created when starting the pipeline
                scp_upload(ssh, "0-queueConversion", to = hpcLogDir)
              }
              
              ### Remove tmp dir
              #unlink(tmpDir, recursive = TRUE)          
              
              ### Done
              session$sendCustomMessage(type = "testmessage",
                                        message = "Samples will be processed @HPC cluster. This will take several hours! You will receive an email when finished.")
              stopApp(returnValue = invisible())
            }
          }
        }
      }
    })
    ### End run
  })
}