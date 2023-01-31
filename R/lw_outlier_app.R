# Shiny app to interactively identify outliers

library(readr)
library(dplyr)
library(shiny)
library(plotly)
library(ggplot2)

ui <- fluidPage(
  "Point and click to select data points that may be outliers. Selected data will appear in the table below and can be downloaded as a csv for further inspection.",
  br(),
  br(),
  plotlyOutput("LengthWeight"),
  br(),
  br(),
  tableOutput("info"),
  br(),
  br(),
  downloadButton("downloadData", "Download")
)

server <- function(input, output) {
  
  # Available length-weight pairs were indentified in the survey_data.R script
  akslope <- readRDS('data/surveys/AFSCslope/AFSCslope_lengthweight_pairs.rda')
  combo <- readRDS('data/surveys/NWFSCcombo/NWFSCcombo_lengthweight_pairs.rda')
  names(akslope) == names(combo)
  
  # make sure there are no NAs
  akslope %>% filter(is.na(Length_cm), is.na(Weight), is.na(Sex))
  combo %>% filter(is.na(Length_cm), is.na(Weight), is.na(Sex))
  
  # combine surveys into single df and define state water areas
  dat <- bind_rows(akslope %>% mutate(survey = 'AFSCslope'), 
                   combo %>% mutate(survey = 'NWFSCcombo')) %>% 
    mutate(state = dplyr::case_when(Latitude_dd < 34.5 ~ 'CA',
                                    Latitude_dd >= 34.5 & Latitude_dd < 40.5 ~ 'OR',
                                    Latitude_dd >= 40.5 ~ 'WA'),
           rn = row_number())

  output$LengthWeight <- renderPlotly({
    
    # key <- highlight_key(dat) # alternative to customdata
    key <- dat
    
    gg1 = key %>% 
      ggplot(aes(x = Length_cm, y = Weight, shape = Sex, colour = Sex, text = rn, customdata = rn)) +
      geom_point() 
    
    ggplotly(gg1, source = "Plot1") 
  })
  
  output$info <- renderTable({
    d <- event_data(event = "plotly_click", source = "Plot1", priority = 'event')
    
    if (is.null(d)) {
      "Point and click to add selected data."
    } else {
      
      tmp <- dat %>%
        filter(rn %in% d$customdata) 
      if(!exists("full")) {full <<- tmp} else { full <<- bind_rows(full, tmp)}
      full
      
      datasetInput <- full  
    }
  })
  
  
  output$downloadData <- downloadHandler(
    filename = 'potential_lw_outliers.csv',
    content = function(file) {
      write.csv(full, file, row.names = FALSE)
    }
  )
  
}

shinyApp(ui = ui, server = server)