library(shiny)
library(shinydashboard)
library(fontawesome)
library(knitr)
library(plotly)
library(data.table)
library(DT)
library(heatmaply)
library(kableExtra)

make.delta.plot <- function(dt, PC){
    fplot <- ggplot(dt, aes(x = reorder(Label, -Delta), y = Delta, ymin=Delta-ci, ymax=Delta+ci, colour = Trait_class))+
      geom_pointrange()+
      scale_colour_manual(values = c("Basis" = "red", "IMD" = "#26547c", "BMK" = "#049F76", "INF" = "#E09D00", "CAN" = "#F3B8A5", "OTH" = "black"))+
      geom_hline(yintercept = 0, col="red", lty=2)+
      coord_flip()+
      xlab("Traits")+
      ylab("Delta")+
      ggtitle(paste0("Delta Plot PC", PC))+
      theme_minimal()+
      theme(legend.position = "bottom")
    fplot
}

make.biplot <- function(dt, PCx, PCy){
  bplot <-  ggplot(dt, aes(x = Delta_x, y = Delta_y, colour = Trait_class, label=Label))+
    geom_hline(yintercept = 0)+
    geom_vline(xintercept = 0)+
    geom_point()+
    scale_colour_manual(values = c("BC" = "#7552A3", "IMD" = "#26547c", "BMK" = "#049F76", "INF" = "#E09D00", "CAN" = "#F3B8A5", "OTH" = "black"))+
    xlab(paste0("Delta ", PCx))+
    ylab(paste0("Delta ", PCy))+
    theme_minimal()+
    theme(legend.title = element_blank(), legend.position = "none", axis.title = element_text(size =15))
  bplot  
  
  
}