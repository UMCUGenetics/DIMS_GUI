function(input, output, session) {
  observe({
    
    shinyDirChoose(input, "raw_file_location", roots = c(home=root))
    shinyFileChoose(input, "experimental_design", roots = c(home=root2))
    
    ### Start Select Raw File Location
    observeEvent(input$raw_file_location, {
      inputDirName <<- paste(as.vector(unlist(input$raw_file_location['path']))[-1], collapse = "/", sep="")
      updateTextInput(session, "run_name", value = gsub(" ","_",inputDirName))
      
    })
    ### End Select Raw File Location
    
    ### Start Select Experimental Design
    observeEvent(input$experimental_design, {
      
      if (!is.na(input$experimental_design['files'])) {
        file <- paste(as.vector(unlist(input$experimental_design['files'])), collapse = "/", sep="")
        df <<- read.csv(paste0(root2, file),
                        header = TRUE,
                        sep = "\t",
                        quote = "")
        
        x=1:dim(df)[1]
        names(x)=df$Sample_Name
        updateCheckboxGroupInput(session, inputId = "inCheckboxGroup", choices = as.list(x), selected = as.list(x))
      }
    })
    ### End Select Experimental Design
    
    ### Start select all
    observeEvent(input$check_all, {
      if (length(df) > 0) {
        x=1:dim(df)[1]
        names(x)=df$Sample_Name
        if (length(input$inCheckboxGroup) > 0) {
          updateCheckboxGroupInput(session, "inCheckboxGroup", choices = as.list(x), selected = NULL)
        } else {
          updateCheckboxGroupInput(session, "inCheckboxGroup", choices = as.list(x), selected = as.list(x))
        }
      }
    })
    ### End select all
    
    ### Start check individual
    observeEvent(input$inCheckboxGroup, {
      output$contents = renderTable(df[input$inCheckboxGroup,][1], 
                                    striped = TRUE, 
                                    hover = TRUE, 
                                    colnames = FALSE)
      if (is.null(input$inCheckboxGroup)) {
        updateActionButton(session, "check_all", label = "Select All")
      } else {
        updateActionButton(session, "check_all", label = "Deselect All")
      }
    }, ignoreNULL = FALSE)
    ### End check individual 
    
    ### Start run
    observeEvent(input$run, {
      ### Check if there is input
      if (is.na(input$raw_file_location['path'])) {
        session$sendCustomMessage(type = "testmessage", message = "Choose a file location!")
      } else if (is.na(input$experimental_design['files'])) {
        session$sendCustomMessage(type = "testmessage", message = "Choose an experimental design!")
      } else if (input$email == '') {
        session$sendCustomMessage(type = "testmessage", message = "Enter your email!")
      } else if (input$run_name == '') {
        session$sendCustomMessage(type = "testmessage", message = "Enter a name for the run!")
      } else {
        
        ### Create all the paths 
        hpcInputDir = paste(base, "raw_data", input$run_name, sep="/")
        hpcLogDir = paste(base, "processed", input$run_name, "logs", "queue", sep="/")
        
        ### Check samples with design
        samplesDesign = paste(as.vector(unlist(df[input$inCheckboxGroup, 1])), "raw", sep=".")
        raw = list.files(path = paste(root, inputDirName, sep="/"), pattern = "raw")
        index = which(samplesDesign %in% raw)
        
        
        if (length(samplesDesign) != length(index)) {
          session$sendCustomMessage(type = "testmessage",
                                    message = "Design and mzXML files differ!")
        } else {
          
          ### Make init.RData (repl.pattern)
          sampleNames=trimws(as.vector(unlist(df$File_Name)))
          nsampgrps = length(sampleNames)/input$nrepl # number of individual biological samples
          groupNames=trimws(as.vector(unlist(df$Sample_Name)))
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
            save(repl.pattern, file=paste(tmpDir, "init.RData", sep="/")) 
            
            ### Save sample sheet
            write.table(df[input$inCheckboxGroup,], file=paste(tmpDir, "sampleNames_out.txt", sep="/"), quote = FALSE, sep="\t",row.names = FALSE)
            files=paste(root, inputDirName, paste(as.vector(unlist(df[input$inCheckboxGroup, 1])),"raw", sep="."), sep="/")
            
            output$samples = renderTable({ as.data.frame(files) })
            
            selectedSamples = df[input$inCheckboxGroup,]
            save(selectedSamples, file=paste(tmpDir, "selectedSamples.RData", sep="/"))
            remove = which(sampleNames %in% selectedSamples$File_Name)
            rval = NULL
            if (length(remove)>0) rval = removeFromRepl.pat(sampleNames[-remove], repl.pattern, groupNamesUnique, input$nrepl)
            
            repl.pattern=rval$pattern
            save(repl.pattern, file=paste(tmpDir, "init.RData", sep="/"))
            
            ### Create settings.config
            fileConn = file(paste(tmpDir, "settings.config", sep = "/"))
            parameters <- c(
              paste("# Created by", commit, "on", format(Sys.time(), "%b %d %Y %X")),
              paste0("thresh_pos=", input$thresh_pos),
              paste0("thresh_neg=", input$thresh_neg),
              paste0("dims_thresh=", input$dims_thresh),
              paste0("trim=", input$trim),
              paste0("nrepl=", input$nrepl),
              paste0("normalization=", input$normalization),
              paste0("thresh2remove=", input$thresh2remove),
              paste0("resol=", input$resol),
              paste0("email=", input$email),
              paste0("proteowizard=", proteowizardDir),
              paste0("db=", db)
            )
            
            writeLines(parameters, fileConn, sep = "\n")
            close(fileConn)
            
            
            ### Connect to HPC
            if (exists("ssh_key")) {
              ssh = ssh_connect(ssh_host, ssh_key)
            } else {
              ssh = ssh_connect(ssh_host)
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
              inputDir = paste(root, inputDirName, sep="/")
              message(paste0("Uploading files from ",inputDir ," to: ", hpcInputDir, " (ignore the %)"))
              for (s in samplesDesign) {
                scp_upload(ssh, paste(inputDir, s, sep="/"), to = hpcInputDir)
              }
              
              ### Copy over the tmp files (eg. init.RData, settings.config)
              message(paste("Uploading files from", tmpDir, "to:", hpcInputDir))
              scp_upload(ssh, list.files(tmpDir, full.names = TRUE), to = hpcInputDir)
              
              if (run_pipeline) {
                ### Start the pipeline
                cmd = paste0("cd ", scriptDir, " && sh run.sh -n ", input$run_name)
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
              message("Done")
              stopApp(returnValue = invisible())
            }
          }
        }
      }
    })
    ### End run
  })
}