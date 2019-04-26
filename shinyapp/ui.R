
# Define UI
shinyUI(
    dashboardPage(
        dashboardHeader(title = 'Where is Waldo?'),
        dashboardSidebar(
          tags$style(HTML("
              @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
                  h4 {
                        font-family: 'Arial';
                        font-weight: 10;
                        color: white;
                        line-height: 1.1;
                        padding: 0px 10px 0px 10px;
                      }
                  h5 {
                        font-family: 'Arial';
                        font-weight: 6;
                        padding: 10px 10px 0px 10px;
                      }        
                          ")),
          tags$h4('Tensorflow Hardware Benchmarking'),
          tags$p(),
                sliderInput("selectSeconds", 
                            label = "Percent of 75-Minute Runtime:",
                            min = 0,
                            max = 100,
                            post ="%",
                            value = c(min, max),
                            sep = ""
                        ),
                selectInput("selectTag",
                            label = "Training Resource:",
                            choices = dropDownTags,
                            multiple = TRUE,
                            selected = unlist(dropDownTags))
                ),
        
        dashboardBody(
           tabsetPanel(
             tabPanel(
               title = "Custom BASH Shell Script",
               uiOutput("googleSheet")
             ),
             tabPanel(
                title = "Processor Utilization", status = "primary", solidHeader = TRUE,
                plotlyOutput("cpu", height = 600)
              ),
            tabPanel(
                title = "Disk I/O",
                plotlyOutput("disk", height = 600)
              ),
            tabPanel(
              title = "Memory Usage",
              plotlyOutput("mem", height = 600)
            ),
            tabPanel(
              title = "Processor Run Heat",
              plotlyOutput("cpuTemp", height = 600)
            ),
            tabPanel(
              title = "GPU Run Heat",
              plotlyOutput("gpuTemp", height = 600)
            ),
            tabPanel(
              title = "Find Waldo - Part 1",
              tags$p(),
              actionButton("buttonGPU1", "GPU Trained"),
              actionButton("buttonCPU1", "CPU Trained"),
              tags$p(),
              plotOutput("findIMG1", height = 768)
            ),
            tabPanel(
              title = "Find Waldo - Part 2",
              tags$p(),
              actionButton("buttonGPU3", "GPU Trained"),
              actionButton("buttonCPU3", "CPU Trained"),
              tags$p(),
              plotOutput("findIMG3", height = 768)
            )
         )
      )
    )
 )