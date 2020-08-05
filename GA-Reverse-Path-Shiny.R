# Rename this file to app.R to run as a Shiny app. 
# Requires that a "service_account.json" file exist providing access to the specified Google Analytics account and view.

require(shiny)
require(visNetwork)
library(tidyverse)
options(
    googleAuthR.scopes.selected = "https://www.googleapis.com/auth/analytics.readonly",
    googleAuthR.client_id = "foo"
    )
library(googleAuthR)
gar_auth_service(json_file="service_account.json")
library(googleAnalyticsR)
account_id <- XXX # Update this with your GA account ID
view_id <- XXX # Updaet this with your GA view ID

getPagePaths <- function(date1, date2){
  google_analytics(viewId = view_id, date_range = c(date1, date2),
                   dimensions = "pagePath", metrics = c("sessions")) %>%
    filter(sessions > 1) %>% arrange(desc(sessions)) %>% select(pagePath) %>% pull()
  
}
getNodesEdges <- function(date1,date2,target_pagePath){

# Grab GA data
se <- segment_element("pagePath", operator = "EXACT", type = "DIMENSION", expression = target_pagePath)
sv <- segment_vector_simple(list(list(se)))
sd <- segment_define(list(sv))
goal_seg <- segment_ga4("visited target page", session_segment = sd)


ga <- google_analytics(viewId = view_id, date_range = c(date1,date2),
                       metrics = c("pageviews"), dimensions = c("pagePath","dimension5", "dimension6", "previousPagePath"),
                       segments = list(goal_seg)) %>% 
  rename(sessionId = dimension5, timestamp = dimension6) %>% 
  select(-segment,-pageviews) %>%
  # Remove query strings
  mutate(pagePath = str_replace_all(pagePath, "\\?.*", "")) %>%
  mutate(previousPagePath = str_replace_all(previousPagePath, "\\?.*","")) %>%
  # Remove instances where previous page path is same as current
  filter(!previousPagePath == pagePath)

# Remove pages after the goal was reached
# Filter to sessions with >1 page

ga_levels <- ga %>% arrange(sessionId, timestamp) %>% 
  # Determine reverse path level where 0 is the page of interest
  group_by(sessionId) %>% 
  mutate(rn = row_number()) %>%
  mutate(target_rn = if_else(pagePath == target_pagePath, rn,as.integer(999))) %>%
  filter(rn <= min(target_rn)) %>% select(-target_rn) %>% 
  # Set target page as 0
  mutate(rn = max(rn) - rn) %>%
  ungroup() %>%
  # GA is weirdly returning some sessions that don't include the targeted page. Remove any instances where the end page isn't the target page
  filter((rn == 0 & pagePath == target_pagePath) | (rn != 0 & pagePath != target_pagePath))

nodes_next <- ga_levels %>% group_by(pagePath,rn) %>% count() %>% mutate(id = paste(pagePath, rn)) %>% rename(label = pagePath, level = rn) %>% ungroup() %>%
  mutate(color = case_when(label == target_pagePath ~ "#aa78a6",
                           T ~ "#b4d6d3")) %>% rename(value = n) %>% select(id, value, color, label, level)

# Additionally, create set of nodes which are the previous path to the first page path
nodes_prev <- ga_levels %>% group_by(previousPagePath,rn) %>% count() %>% 
  filter(rn == max(rn)) %>% 
  ungroup() %>%
  mutate(rn = rn+1) %>%
  mutate(id = paste(previousPagePath, rn)) %>% 
  rename(label = previousPagePath) %>% 
  rename(value = n, level = rn) %>% mutate(color = "#b4d6d3") %>% 
  select(id, value, color, label,level)

# Merge data frames while summing the node count if the level and page path are the same
nodes <- nodes_next %>% bind_rows(nodes_prev) %>% group_by(id,color,label,level) %>% summarise(value = sum(value)) %>% mutate(title = label) %>% ungroup() %>%
  # Remove lon gnode 
  mutate(label = if_else(stringr::str_length(label) < 12, label, ""))

edges <-  ga_levels %>% group_by(previousPagePath, pagePath, rn) %>% count() %>% ungroup() %>% mutate(from = paste(previousPagePath, rn+1), to = paste(pagePath, rn)) %>% select(-previousPagePath, -pagePath) %>% rename(width = n) %>% mutate(title = width) %>%
  # Rescale width to stay within reason
  mutate(width = (width / max(width) * 10))
  

return(list(nodes,edges))


}

server <- function(input, output, session) {
  
    network_objs <- reactive({
        getNodesEdges(input$date[1],input$date[2], input$selPagePath)
    })
    
    pagePaths <- reactive({
      req(input$date)
      getPagePaths(input$date[1],input$date[2])
    })
    
    output$network <- renderVisNetwork({
        req(input$selPagePath)
        nodesEdges <- network_objs()
        visNetwork(nodes = nodesEdges[[1]], edges = nodesEdges[[2]], width = "100%", height = "1200px") %>%
            visEdges(arrows = "to") %>%
            visHierarchicalLayout()
    })
    
    output$selPagePath <- renderUI({
      selectInput("selPagePath", "Page:", choices = pagePaths())
    })
}

ui <- fluidPage(
  tags$head(tags$style(type="text/css", ".container-fluid {  max-width: 1200px;}")),
  titlePanel("Reverse Path Analysis with Google Analytics Data"),
  sidebarLayout(
    
    sidebarPanel(
      div(
        (
        "Select a date range and page below to visualize paths that visitors took to reach that page. 
        Node and edge sizes correspond to the number of sessions. 
        Page views that occur after the user reaches the page of interest are ignored",
        ),
        p(
          "Hover over the nodes to view the page it represents. Hover over edges to view how many sessions took that path."
        )
        
        ),
      dateRangeInput(inputId = "date",
                     strong("Date Range:"),
                     start = Sys.Date()-10, end = Sys.Date(),
                     min = "2020-01-01", max =Sys.Date() ),
      uiOutput("selPagePath")
    ),
    
    mainPanel(
      visNetworkOutput("network")
    )
  )
    
)

shinyApp(ui = ui, server = server)