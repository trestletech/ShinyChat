ShinyChat
=========

Chat client built in Shiny.

This branch demonstrates the usage of Shiny Server Pro's authentication to automatically set the usernames for each user. You can combine this with `auth_google` and `required_user *` to require the users login using their Google accounts, in which case their emails addresses will serve as their usernames for chatting. 

By default, we censor email addresses by substituting the second half of the username with asterisks to avoid disclosing anyone's email address publicly.