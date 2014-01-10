library(shiny)

shinyUI(
  bootstrapPage(
    includeCSS("shinychat.css"),
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
            textInput("entry", ""),
            actionButton("send", "Send")
          )

        ),
        sidebarPanel(
          textInput("user", "Your User ID:", value=""),
          uiOutput("userList"),
          helpText(HTML("Source code available <a href =\"https://github.com/trestletech/ShinyChat\">on GitHub</a>."))
        )
      )
    )
  )
)
