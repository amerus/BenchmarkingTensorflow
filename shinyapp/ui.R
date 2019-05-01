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
                selectInput("selectHardware",
                            label = "",
                            choices = selHard,
                            multiple = TRUE,
                            selected = unlist(head(selHard, n = 1)),
                            selectize = FALSE, size = 7
                        ),
                selectInput("selectTag",
                            label = "",
                            choices = dropDownTags,
                            multiple = TRUE,
                            selected = unlist(dropDownTags),
                            selectize = FALSE, size = 3
                            ),
                tags$hr(width='50%'),
                selectInput(
                          "selectWaldo",
                          label = "Choose Waldo Image:",
                          choices = selWaldo,
                          selected = "",
                          selectize = FALSE, size = 7
                          ),
                radioButtons(
                          "radioWaldo",
                          label = NULL,
                          choices = c("CPU Trained", "GPU Trained"),
                          selected = "CPU",
                          inline = TRUE
                          ),
                actionButton("btnWaldo", "Find Waldo")
                ),
        
        dashboardBody(
           tabsetPanel(id="myTabs",
             tabPanel(
               title = "BASH Shell Script",
               codeOutput("shellScript")
             ),
             tabPanel(
                title = "Processor Utilization",
                plotOutput("cpu", height = 600)
              ),
            tabPanel(
                title = "Disk Utilization",
                plotOutput("disk", height = 600)
              ),
            tabPanel(
              title = "Memory Utilization",
              plotOutput("mem", height = 600)
            ),
            tabPanel(
              title = "Processor Temperature",
              plotOutput("cpuTemp", height = 600)
            ),
            tabPanel(
              title = "Graphics Temperature",
              plotOutput("gpuTemp", height = 600)
            ),
            tabPanel(
              title = "Combined Bar Chart",
              plotOutput("ALL", height = 600)
            ),
            tabPanel(
              title = "Waldo",
              plotOutput("defaultImage", height = 768)
            )
         )
         
      )
    )
 )