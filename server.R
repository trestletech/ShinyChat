library(shiny)
library(stringr)

# Globally define a place where all users can share some reactive data.
vars <- reactiveValues(chat=NULL, users=NULL)

# Restore the chat log from the last session.
if (file.exists("chat.Rds")){
  vars$chat <- readRDS("chat.Rds")
}

#' Get the prefix for the line to be added to the chat window. Usually a newline
#' character unless it's the first line.
linePrefix <- function(){
  if (is.null(isolate(vars$chat))){
    return("")
  }
  return("<br />")
}

shinyServer(function(input, output, session) {
  
  # Track whether or not this session has been initialized. We'll use this to
  # assign a username to unininitialized sessions.
  init <- FALSE
  
  # When a session is ended, remove the user and note that they left the room. 
  session$onSessionEnded(function() {
    isolate({
      vars$users <- vars$users[vars$users != session$user]
      vars$chat <- c(vars$chat, paste0(linePrefix(), "<span class=\"user-exit\">\"", 
                                        sanitize(session$user),
                                        "\" left the room.</span>"))
    })
  })
  
  # Observer to handle changes to the username
  observe({
    isolate({
      if (is.null(session$user)){
        print("No username available. This application is intended to be hosted by Shiny Server Pro with required authentication.")
      }
      vars$chat <<- c(vars$chat, paste0(linePrefix(), "<span class=\"user-enter\">\"", 
                                       sanitize(session$user),
                                       "\" entered the room.</span>"))
    })    
    
    # Add this user to the global list of users
    isolate(vars$users <- c(vars$users, session$user))
  })
    
  # Keep the list of connected users updated
  output$userList <- renderUI({
    tagList(tags$ul( lapply(vars$users, function(user){
      return(tags$li(user))
    })))
  })
  
  # Listen for input$send changes (i.e. when the button is clicked)
  observe({
    if(input$send < 1){
      # The code must be initializing, b/c the button hasn't been clicked yet.
      return()
    }
    isolate({
      # Add the current entry to the chat log.
      vars$chat <<- c(vars$chat, 
                      paste0(linePrefix(), "<span class=\"username\">",
                             "<abbr title=\"", Sys.time(), "\">", session$user,
                             "</abbr></span>: ", sanitize(input$entry)))
    })
    # Clear out the text entry field.
    updateTextInput(session, "entry", value="")
  })
  
  # Dynamically create the UI for the chat window.
  output$chat <- renderUI({
    if (length(vars$chat) > 500){
      # Too long, use only the most recent 500 lines
      vars$chat <- vars$chat[(length(vars$chat)-500):(length(vars$chat))]
    }
    # Save the chat object so we can restore it later if needed.
    saveRDS(vars$chat, "chat.Rds")
    
    # Pass the chat log through as HTML
    HTML(vars$chat)
  })
})

# Replace any HTML tags in user-provided strings to prevent malicious entries.
sanitize <- function(string){
  str_replace_all(string, "[<>]", "")
}