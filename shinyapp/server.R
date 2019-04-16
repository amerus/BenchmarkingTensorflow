
# Define server logic required to draw a plot
shinyServer(function(input, output) {
  
  output$cpu <- renderPlotly({
   ggplotly({
    # filter CPU utilization to reflect user selections
    data <- CPU %>%
      filter(seconds >= input$selectSeconds[1] & seconds <= input$selectSeconds[2]) %>%
      filter(execution %in% input$selectTag)
      
    # increase the number of colors of brewer with colorRampPalette  
    #colourCount = length(unique(data$Tag))
    #getPalette = colorRampPalette(brewer.pal(12, "Paired"))
    
    # create plot from filtered data
      ggplot(data, aes(x = seconds, y = utilization, col = execution)) +
        geom_smooth(aes(group=execution), method="auto", se=FALSE) +
        theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
      #geom_line(aes(group = Tag, linetype = Tag)) +
      #scale_color_manual(values = getPalette(colourCount)) +
      #facet_grid(. ~ Language) +
      #theme(text = element_text(size=20),
      #      axis.text.x = element_text(hjust = 1, size = 7),
      #      axis.ticks.y = element_blank(),
      #      axis.text.y = element_blank(),
      #      plot.margin = (unit(c(0.5, 0.5, 0.5, 1), "cm")),
      #      panel.spacing = unit(1.5, "lines"),
      #      legend.text = element_text(size = 7),
      #      legend.title = element_blank()) +
      # scale_x_discrete(expand = c(0, 0)) +
      xlab("Seconds") +
      ylab("Processor Utilization")
    }) # %>%
      #layout(legend = list(x = 1, y = 1))
  })
  
  output$disk <- renderPlotly({
    ggplotly({
      
      data <- DISK %>%
        filter(seconds >= input$selectSeconds[1] & seconds <= input$selectSeconds[2]) %>%
        filter(execution %in% input$selectTag) # %>%

      ggplot(data, aes(x = seconds, y = util, col = execution)) +
        geom_smooth(aes(group=execution), method = "auto", se = FALSE) +
        theme(
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              axis.title.x = element_text(size = 10)) +
        ylab("Disk I/O") +
        xlab("Seconds")
    })
  })

  output$mem <- renderPlotly({
    ggplotly({
      
      data <- MEM %>%
        filter(seconds >= input$selectSeconds[1] & seconds <= input$selectSeconds[2]) %>%
        filter(execution %in% input$selectTag) 
      
      ggplot(data, aes(x = seconds, y = Memory, col = execution)) +
        geom_smooth(aes(group=execution), method="auto", se=FALSE) +
        theme(
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_text(size = 20)) +
        ylab("Memory Usage") +
        xlab("Seconds")
    })
  })  
  
    observeEvent(input$buttonGPU3, {
      system("python3 ./find_wally_GPU.py waldo/images/3.jpg")
  })  
  
    observeEvent(input$buttonGPU1, {
      system("python3 ./find_wally_GPU.py waldo/images/1.jpg")
    })  
    
    observeEvent(input$buttonCPU3, {
      system("python3 ./find_wally_CPU.py waldo/images/3.jpg")
    })  
    
    observeEvent(input$buttonCPU1, {
      system("python3 ./find_wally_CPU.py waldo/images/1.jpg")
    })  
    
  output$findCPU3 <- renderImage({
    
      # When input$n is 3, filename is ./images/image3.jpeg
      filename <- normalizePath(file.path('./waldo/images', paste('3', input$n, '.jpg', sep='')))
    
      # Return a list containing the filename and alt text
      list(src = filename, width=1024, height=768,
           alt = paste("Image number", input$n))
      
    }, deleteFile = FALSE)

  output$findGPU1 <- renderImage({
  
  # When input$n is 3, filename is ./images/image3.jpeg
  filename <- normalizePath(file.path('./waldo/images', paste('1', input$n, '.jpg', sep='')))
  
  # Return a list containing the filename and alt text
  list(src = filename, width=1024, height=768,
       alt = paste("Image number", input$n))
  
  }, deleteFile = FALSE)

})


