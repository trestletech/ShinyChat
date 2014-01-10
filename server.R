library(shiny)

vars <- reactiveValues(chat=NULL, users=NULL)

linePrefix <- function(){
  if (is.null(isolate(vars$chat))){
    return("")
  }
  return("<br />")
}

shinyServer(function(input, output, session) {
  sessionVars <- reactiveValues(username = "")
  
  session$onSessionEnded(function() {
    isolate({
      vars$users <- vars$users[vars$users != sessionVars$username]
      vars$chat <- c(vars$chat, paste0(linePrefix(), "<span class=\"user-exit\">\"", 
                                        sessionVars$username,
                                        "\" left the room.</span>"))
    })
  })
  
  observe({
    if (input$user == ""){
      # Seed initial username
      sessionVars$username <- paste0("User", round(runif(1, 10000, 99999)))
      isolate({
        vars$chat <<- c(vars$chat, paste0(linePrefix(), "<span class=\"user-enter\">\"", 
                                         sessionVars$username,
                                         "\" entered the room.</span>"))
      })
    } else{
      isolate({
        if (input$user == sessionVars$username){
          # No change. Just return.
          return()
        }
        
        # Updating username      
        # First, remove the old one
        vars$users <- vars$users[vars$users != sessionVars$username]
        
        vars$chat <<- c(vars$chat, paste0(linePrefix(), "<span class=\"user-change\">\"", 
                                          sessionVars$username, "\" -> \"", 
                                          input$user, "\"</span>"))
        
        # Now update with the new one
        sessionVars$username <- input$user
      })
    }
    isolate(vars$users <- c(vars$users, sessionVars$username))
  })
  
  # Keep the username updated
  observe({
    updateTextInput(session, "user", 
                    value=sessionVars$username)    
  })
  
  output$userList <- renderUI({
    tagList(tags$ul( lapply(vars$users, function(user){
      return(tags$li(user))
    })))
  })
  
  observe({
    if(input$send < 1){
      return()
    }
    isolate({
      vars$chat <<- c(vars$chat, paste0(linePrefix(), input$user, ": ", 
                                                          input$entry))
    })
    updateTextInput(session, "entry", value="")
  })
  
  output$chat <- renderUI({
    HTML(vars$chat)
  })
})
