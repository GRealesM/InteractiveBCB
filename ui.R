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
library(fontawesome)
library(knitr)

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
  dashboardSidebar(
    sidebarMenu(
      HTML(paste(p( HTML('&nbsp;'), strong("_______________________")))),
      HTML(paste( p( HTML('&nbsp;'), strong("Single Feature visualisation")))),
      menuItem("Delta Plots", tabName = "dplots", icon = icon("signal")),
      menuItem("Projection Table", tabName = "projtables", icon = icon("rectangle-list")),
      sliderInput("PCDelta", label = "Feature / PC:", min=1, max=14, value = 1),
      HTML(paste(p( HTML('&nbsp;'), strong("_______________________")))),
      HTML(paste( p( HTML('&nbsp;'), strong("Multiple Feature visualisation")))),
      menuItem("Biplots", tabName = "biplots", icon = icon("share-nodes")),
      sliderInput("b1", label = "Feature on X axis", min=1, max=14, value = 1),
      sliderInput("b2", label = "Feature on Y axis", min=1, max=14, value = 2),
      HTML(paste(p( HTML('&nbsp;'), strong("_______________________")))),
      menuItem("Dataset info", tabName= "dstable", icon = icon("flask")), 
      menuItem("Help", tabName = "Help", icon = icon("book-open", lib = "font-awesome"))
    )
  ),
  
  
  dashboardBody(
    tabItems(
      tabItem("dplots", fluidRow(column(12, box(plotlyOutput("Delta") , width = 12, height = "2100px") ) ) ),
      tabItem("projtables", fluidRow(column(div(style = "font-size: 10px;
                   padding: 20px 0px;
                   margin:0%"), DT::dataTableOutput("ptables"), width = 12))),
      tabItem("dstable", fluidRow(column(div(style = "font-size: 10px;
                   padding: 20px 0px;
                   margin:0%"), DT::dataTableOutput("dstables"), width = 12))),
      tabItem("biplots", fluidRow(column(12, box(plotlyOutput("biplot") , width = 12) ) ) ),
      tabItem("Help", fluidRow(column(12, HTML(markdown::markdownToHTML(knit("help.Rmd", quiet = TRUE))))))
    )
  )
)
