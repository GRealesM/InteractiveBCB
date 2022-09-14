#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

##############################
###       FUNCTIONS        ###
##############################

# Custom function for dropdown menu on the board header
# dropdownMenuCustom <-     function (..., type = c("messages", "notifications", "tasks"),
#                                     badgeStatus = "primary", icon = NULL, .list = NULL,
#                                     customSentence = customSentence){
#   type <- match.arg(type)
#   if (!is.null(badgeStatus)) shinydashboard:::validateStatus(badgeStatus)
#   items <- c(list(...), .list)
#   lapply(items, shinydashboard:::tagAssert, type = "li")
#   dropdownClass <- paste0("dropdown ", type, "-menu")
#   if (is.null(icon)) {
#     icon <- switch(type, messages = shiny::icon("envelope"),
#                    notifications = shiny::icon("warning"), tasks = shiny::icon("tasks"))
#   }
#   numItems <- length(items)
#   if (is.null(badgeStatus)) {
#     badge <- NULL
#   }
#   else {
#     badge <- tags$span(class = paste0("label label-", badgeStatus),
#                        numItems)
#   }
#   tags$li(
#     class = dropdownClass,
#     a(
#       href = "#",
#       class = "dropdown-toggle",
#       `data-toggle` = "dropdown",
#       icon,
#       badge
#     ),
#     tags$ul(
#       class = "dropdown-menu",
#       tags$li(
#         class = "header",
#         customSentence(numItems, type)
#       ),
#       tags$li(
#         tags$ul(class = "menu", items)
#       )
#     )
#   )
# }

# Define UI for application that draws a histogram
dashboardPage(
  dashboardHeader(title = "Interactive BCB",
                  dropdownMenu( type = 'message',icon = icon("github"), badgeStatus = NULL, headerText = "Check out the Github page!", messageItem(from = 'Github', message = "", icon = icon("github"), href = "https://github.com/GRealesM/InteractiveBCB"))
                  ),
  dashboardSidebar(),
  dashboardBody()
)
