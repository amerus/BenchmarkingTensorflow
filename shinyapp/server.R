CPUScript <- "./data/collect_cpu.sh"
GPUScript <- "./data/collect_gpu.sh"

shinyServer(function(input, output) {
  
  # Hiding and showing individual tabs upon selection
  observeEvent(input$selectHardware, {
    
    tabData <- input$selectHardware
    
    # Hide all tabls as ANY selection is recorded
    for(val in unlist(selHard)){
      hideTab("myTabs", val)
      # If fewer than 2 hardware components are selected, hide the comparison tab
      if(length(tabData) < 2){
        hideTab("myTabs","Combined Bar Chart")
      }
    }
    
    # Showing individual tabs upon selection
    for(val in unlist(tabData)){
      showTab("myTabs", val, select=TRUE)
      
      if(length(tabData) >= 2){
        showTab("myTabs","Combined Bar Chart", select=TRUE)
      }
    }
    
  })
  
  # Updating shell script display upon selection. Uses codeModules library
  output$shellScript <- renderCode({
    if(unlist(head(input$selectTag, n = 1)) == "Processor"){
      script = CPUScript
    } else {
      script = GPUScript
    }
    read_file(script)
  })
 
  # Function to be reused inside of each tab. Returns basic ggplot, which interacts with all of the inputs
  getPlotData <- function(incomingData) {
    data <- incomingData %>%
      filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
      filter(Hardware %in% input$selectHardware) %>%
      filter(execution %in% input$selectTag)
    
    ggBasic <- ggplot(data, aes(x = seconds, y = Utilization, col = execution)) +
      stat_smooth(aes(group=execution), method="loess", span=0.05, se=FALSE) +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        text = element_text(size=20)) +
      labs(colour="Trained on:") +
      xlab("Seconds")
    
    return(ggBasic)
  }
  
  output$cpu <- renderPlot({
     graph <- getPlotData(ALL)
     graph +
     ylab("Processor Utilization (Percent)")
  })
  
  output$disk <- renderPlot({

      graph <- getPlotData(ALL)
      graph +
      ylab("Disk Utilization (Percent)")
  })

  output$mem <- renderPlot({

      graph <- getPlotData(ALL)
      graph +
      ylab("Memory Utilization (Percent of Total)")
  })  
  
  output$cpuTemp <- renderPlot({

      graph <- getPlotData(ALL)
      graph +
      ylab("Temperature (Percent of Maximum)") 
  })
  
  output$gpuTemp <- renderPlot({

      graph <- getPlotData(ALL)
      graph +
      ylab("Temperature (Percent of Maximum)")
  })
  
  output$ALL <- renderPlot({
    data <- ALL %>%
      filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
      filter(Hardware %in% input$selectHardware) %>%
      filter(execution %in% input$selectTag)

      ggplot(data, aes(reorder(Hardware, Utilization), Utilization, fill=execution)) + geom_col(position="dodge2") +
        coord_flip() +
        theme(text = element_text(size=20),
              axis.text.x = element_text(hjust = 1)) +
        scale_fill_discrete(name = "Trained on:") +
        xlab('Hardware') +
        ylab('Percent Utilization')
  })
  
    observeEvent(input$selectWaldo, {
      showTab("myTabs", "Waldo", select = TRUE)
      
      output$defaultImage <- renderImage({

        filename <- normalizePath(file.path('./waldo/images/', input$selectWaldo))

        list(src = filename, height="100%")
      }, deleteFile = FALSE)
    })
    
    observeEvent(input$btnWaldo, {
      output$defaultImage <- renderImage({
        if(input$radioWaldo == "CPU Trained"){
          filename <- normalizePath(file.path('./waldo/images/cpu', input$selectWaldo))
        } else {
          filename <- normalizePath(file.path('./waldo/images/gpu', input$selectWaldo))
        }
        list(src = filename, height="100%")
      }, deleteFile = FALSE)
    })
})