library(shiny)
library(stringr)

vars <- reactiveValues(chat=NULL, users=NULL)

if (file.exists("chat.Rds")){
  # Restore the chat log from a previous session.
  vars$chat <- readRDS("chat.Rds")
}

linePrefix <- function(){
  if (is.null(isolate(vars$chat))){
    return("")
  }
  return("<br />")
}

shinyServer(function(input, output, session) {
  sessionVars <- reactiveValues(username = "")
  
  init <- FALSE
  
  session$onSessionEnded(function() {
    isolate({
      vars$users <- vars$users[vars$users != sessionVars$username]
      vars$chat <- c(vars$chat, paste0(linePrefix(), "<span class=\"user-exit\">\"", 
                                        sanitize(sessionVars$username),
                                        "\" left the room.</span>"))
    })
  })
  
  observe({
    input$user
    
    if (!init){
      # Seed initial username
      sessionVars$username <- paste0("User", round(runif(1, 10000, 99999)))
      isolate({
        vars$chat <<- c(vars$chat, paste0(linePrefix(), "<span class=\"user-enter\">\"", 
                                         sanitize(sessionVars$username),
                                         "\" entered the room.</span>"))
      })
      init <<- TRUE
    } else{
      isolate({
        if (input$user == sessionVars$username || input$user == ""){
          # No change. Just return.
          return()
        }
        
        # Updating username      
        # First, remove the old one
        vars$users <- vars$users[vars$users != sessionVars$username]
        
        vars$chat <<- c(vars$chat, paste0(linePrefix(), "<span class=\"user-change\">\"", 
                                          sanitize(sessionVars$username), 
                                          "\" -> \"", sanitize(input$user), "\"</span>"))
        
        # Now update with the new one
        sessionVars$username <- sanitize(input$user)
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
      vars$chat <<- c(vars$chat, 
                      paste0(linePrefix(), "<span class=\"username\">",
                             "<abbr title=\"", Sys.time(), "\">", sanitize(input$user),
                             "</abbr></span>: ", sanitize(input$entry)))
    })
    updateTextInput(session, "entry", value="")
  })
  
  output$chat <- renderUI({
    if (length(vars$chat) > 500){
      # Too long, use only the most recent 500 lines
      vars$chat <- vars$chat[(length(vars$chat)-500):(length(vars$chat))]
    }
    saveRDS(vars$chat, "chat.Rds")
    HTML(vars$chat)
  })
})

# Replace any HTML tags
sanitize <- function(string){
  str_replace_all(string, "[<>]", "")
}