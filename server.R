library(shiny)

chat <- reactiveValues(`Pick One...` = NULL, `Sample Room` = NULL)

shinyServer(function(input, output, session) {
  observe({
    if (input$user == ""){
      updateTextInput(session, "user", 
                      value=paste0("User", round(runif(1, 10000, 99999))))  
    }
    
    updateSelectInput(session, "room", selected=input$room,
                      choices=names(reactiveValuesToList(chat)))
  })
  
  observe({
    isolate({
      pre <- ""
      if (!is.null(chat[[input$room]])){
        pre <- "\n"
      }
      chat[[input$room]] <<- c(chat[[input$room]], paste0(pre, input$user, ": ", 
                                                    input$entry))
    })
    input$send
    updateTextInput(session, "entry", value="")
  })
  
  output$roomName <- renderText({
    input$room
  })
  
  output$chat <- renderText({
    chat[[input$room]]
  })
})
