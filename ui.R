library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel(tagList(HTML("ShinyChat"), h4("Hipper than IRC..."))),
  
  sidebarPanel(
    textInput("user", "User ID", value=""),
    selectInput("room", "Chat Room:", choices=c("Pick One..."), selected="Pick One...")
  ),
  
  mainPanel(
    conditionalPanel("input.room != 'Pick One...'",
      textOutput("roomName"),
      verbatimTextOutput("chat"),
      fluidRow(
        textInput("entry", ""),
        actionButton("send", "Send")
      )
    )
  )
))
