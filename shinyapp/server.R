
# Define server logic required to draw a plot
googleSheet_embed_link <- "https://docs.google.com/document/d/1LAVl6OIx56U1hxYDP9QVLPXtlVhvDkwva0A6YAKZJMs"

shinyServer(function(input, output) {
  
  output$googleSheet <- renderUI({
    tags$iframe(style="height:800px; width:50%", src=googleSheet_embed_link, id="googleSheet")
  })
  
  output$cpu <- renderPlotly({
   ggplotly({
    # filter CPU utilization to reflect user selections
    data <- CPU %>%
      filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
      filter(execution %in% input$selectTag)
    
    # create plot from filtered data
      ggplot(data, aes(x = seconds, y = utilization, col = execution)) +
        stat_smooth(aes(group=execution), method="loess", span=0.1, se=FALSE) +
        theme(
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_text(size = 10)) +
      labs(colour="Running on:") +
      #ylim(0,100) +
      xlab("Seconds") +
      ylab("Processor Utilization (Percent)")
    })
  })
  
  output$disk <- renderPlotly({
    ggplotly({
      
      data <- DISK %>%
        filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
        filter(execution %in% input$selectTag) # %>%

      ggplot(data, aes(x = seconds, y = util, col = execution)) +
        geom_smooth(aes(group=execution), method = "loess", span=0.1, se = FALSE) +
        theme(
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              axis.title.x = element_text(size = 10)) +
        labs(colour="Running on:") +
        #ylim(0,100) +
        ylab("Disk I/O (Percent)") +
        xlab("Seconds")
    })
  })

  output$mem <- renderPlotly({
    ggplotly({
      
      data <- MEM %>%
        filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
        filter(execution %in% input$selectTag) 
      
      ggplot(data, aes(x = seconds, y = Memory, col = execution)) +
        geom_smooth(aes(group=execution), method="loess", span=0.1, se=FALSE) +
        theme(
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_text(size = 10)) +
        labs(colour="Running on:") +
        #ylim(0,100) +
        ylab("Memory Usage (Percent of Total)") +
        xlab("Seconds")
    })
  })  
  
  output$cpuTemp <- renderPlotly({
    ggplotly({
      
      data <- CPU_TEMP %>%
        filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
        filter(execution %in% input$selectTag)
      
      ggplot(data, aes(x = seconds, y = Temperature, col = execution)) +
        geom_smooth(aes(group=execution), method = "loess", span=0.05, se = FALSE) +
        theme(
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_text(size = 10)) +
        labs(colour="Running on:") +
        #ylim(0,100) +
        ylab("Temperature (Percent of Maximum)") +
        xlab("Seconds")
    })
  })
  
  output$gpuTemp <- renderPlotly({
    ggplotly({
      
      data <- GPU_TEMP %>%
        filter(seconds >= (max(sliderSeconds) * input$selectSeconds[1] / 100) & seconds <= (max(sliderSeconds) * input$selectSeconds[2]) / 100 ) %>%
        filter(execution %in% input$selectTag) # %>%
      
      ggplot(data, aes(x = seconds, y = Temperature, col = execution)) +
        geom_smooth(aes(group=execution), method = "loess", span=0.05, se = FALSE) +
        theme(
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_text(size = 10)) +
        labs(colour="Running on:") +
        #ylim(0,100) +
        ylab("Temperature (Percent of Maximum)") +
        xlab("Seconds")
    })
  })
  
    observeEvent(input$buttonGPU3, {
      #system("python3 ./find_wally_GPU.py waldo/images/3.jpg")
        output$findIMG3 <- renderImage({
          
          # When input$n is 3, filename is ./images/image3.jpeg
          filename <- normalizePath(file.path('./waldo/images', paste('3gpu', input$n, '.png', sep='')))
          
          # Return a list containing the filename and alt text
          list(src = filename, width=1024, height=768,
               alt = paste("Image number", input$n))
          
        }, deleteFile = FALSE)  
    })
    
    observeEvent(input$buttonGPU1, {
      #system("python3 ./find_wally_GPU.py waldo/images/1.jpg")
      output$findIMG1 <- renderImage({
        
        # When input$n is 3, filename is ./images/image3.jpeg
        filename <- normalizePath(file.path('./waldo/images', paste('1gpu', input$n, '.png', sep='')))
        
        # Return a list containing the filename and alt text
        list(src = filename, width=1024, height=768,
             alt = paste("Image number", input$n))
        
      }, deleteFile = FALSE)  
    })  
    
    observeEvent(input$buttonCPU3, {
      #system("python3 ./find_wally_CPU.py waldo/images/3.jpg")
      output$findIMG3 <- renderImage({
        
        # When input$n is 3, filename is ./images/image3.jpeg
        filename <- normalizePath(file.path('./waldo/images', paste('3cpu', input$n, '.png', sep='')))
        
        # Return a list containing the filename and alt text
        list(src = filename, width=1024, height=768,
             alt = paste("Image number", input$n))
        
      }, deleteFile = FALSE)  
    })  
    
    observeEvent(input$buttonCPU1, {
      #system("python3 ./find_wally_CPU.py waldo/images/1.jpg")
      output$findIMG1 <- renderImage({
        
        # When input$n is 3, filename is ./images/image3.jpeg
        filename <- normalizePath(file.path('./waldo/images', paste('1cpu', input$n, '.png', sep='')))
        
        # Return a list containing the filename and alt text
        list(src = filename, width=1024, height=768,
             alt = paste("Image number", input$n))
        
      }, deleteFile = FALSE)  
    })  
    
  output$findIMG3 <- renderImage({
    
      # When input$n is 3, filename is ./images/image3.jpeg
      filename <- normalizePath(file.path('./waldo/images', paste('3', input$n, '.jpg', sep='')))
    
      # Return a list containing the filename and alt text
      list(src = filename, width=1024, height=768,
           alt = paste("Image number", input$n))
      
    }, deleteFile = FALSE)

  output$findIMG1 <- renderImage({
  
  # When input$n is 3, filename is ./images/image3.jpeg
  filename <- normalizePath(file.path('./waldo/images', paste('1', input$n, '.jpg', sep='')))
  
  # Return a list containing the filename and alt text
  list(src = filename, width=1024, height=768,
       alt = paste("Image number", input$n))
  
  }, deleteFile = FALSE)

})


