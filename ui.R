library(shiny)

shinyUI(
  bootstrapPage(
    # We'll add some custom CSS styling -- totally optional
    includeCSS("shinychat.css"),
    
    # And custom JavaScript -- just to send a message when a user hits "enter".
    # Totally optional.
    includeScript("sendOnEnter.js"),
    
    div(
      class = "container-fluid", 
      div(class = "row-fluid", 
        headerPanel(tagList(HTML("ShinyChat"), h4("Hipper than IRC...")), "ShinyChat")
      ),
      div(
        class = "row-fluid", 
        mainPanel(
          uiOutput("chat"),
          fluidRow(
            div(class="span10",
              textInput("entry", "")
            ),
            div(class="span2 center",
                actionButton("send", "Send")
            )
          )
        ),
        sidebarPanel(
          textInput("user", "Your User ID:", value=""),
          tags$hr(),
          h5("Connected Users"),
          uiOutput("userList"),
          tags$hr(),
          helpText(HTML("Source code available <a href =\"https://github.com/trestletech/ShinyChat\">on GitHub</a>."))
        )
      )
    )
  )
)
