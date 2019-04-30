
# Define server logic required to draw a plot

CPUScript <- "./data/collect_cpu.sh"
GPUScript <- "./data/collect_gpu.sh"

shinyServer(function(input, output) {
  
  output$googleSheet <- renderCode({
    if(unlist(head(input$selectTag, n = 1)) == "Processor"){
      script = CPUScript
    } else {
      script = GPUScript
    }
    read_file(script)
  })

  observeEvent(input$selectHardware, {
    
    tabData <- input$selectHardware
    
    for(val in unlist(selHard)){
      hideTab("myTabs", val)
      if(length(tabData) < 2){
        hideTab("myTabs","Combined Bar Chart")
      }
    }
    
    for(val in unlist(tabData)){
      showTab("myTabs", val, select=TRUE)
      if(length(tabData) >= 2){
        showTab("myTabs","Combined Bar Chart", select=TRUE)
      }
    }
    
  })
  
  getPlotData <- function(incomingData) {
    data <- incomingData %>%
      filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
      filter(Hardware %in% input$selectHardware) %>%
      filter(execution %in% input$selectTag)
    
    ggBasic <- ggplot(data, aes(x = seconds, y = Utilization, col = execution)) +
      stat_smooth(aes(group=execution), method="loess", span=0.1, se=FALSE) +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 15),
        axis.title.x = element_text(size = 20),
        axis.title.y = element_text(size = 20)) +
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
      ylab("Disk I/O (Percent)")
  })

  output$mem <- renderPlot({

      graph <- getPlotData(ALL)
      graph +
      ylab("Memory Usage (Percent of Total)")
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