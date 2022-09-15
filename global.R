library(shiny)
library(shinydashboard)
library(fontawesome)
library(knitr)
library(plotly)
library(data.table)
library(DT)


make.delta.plot <- function(dt, PC){
    fplot <- ggplot(dt, aes(x = reorder(Label, -Delta), y = Delta, ymin=Delta-ci, ymax=Delta+ci, colour = Trait_class))+
      geom_pointrange()+
      scale_colour_manual(values = c("Basis" = "red", "IMD" = "#26547c", "BMK" = "#049F76", "INF" = "#E09D00", "CAN" = "#F3B8A5", "OTH" = "black"))+
      geom_hline(yintercept = 0, col="red", lty=2)+
      coord_flip()+
      xlab("Traits")+
      ylab("Delta")+
      ggtitle(paste0("Delta Plot ", PC))+
      theme_minimal()+
      theme(legend.position = "bottom")
    fplot

}
