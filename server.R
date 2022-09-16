
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  pt = fread("data/PT_sig_202208.tsv")
  qc = fread("data/QC_sig_202208.tsv")
  pb = fread("data/pbasis_202208.tsv")
  pt.viz = pt[!Trait %in% c("M13_GOUT_FinnGen_FinnGenR7_1", "K11_UC_STRICT2_FinnGen_FinnGenR7_1", "FG_DISVEINLYMPH_FinnGen_FinnGenR7_1", "L12_DERMATITISNAS_FinnGen_FinnGenR7_1")] # Remove redundant traits
  id.height <- c(800, # PC1
                 800, # PC2
                 800, # PC3
                 800, # PC4
                 1500, # PC5
                 800, # PC6
                 800, # PC7
                 2000, # PC8
                 800, # PC9
                 800, # PC10
                 800, # PC11
                 700, # PC12
                 800, # PC13
                 900 # PC14
                 )
  
  # Prepare dataset for Delta plots
  pdelta <- pt.viz[stars == "●"][ Trait_class != "BC"] # Remove Blood cells to avoid cluttering
  pdelta <- rbind(pdelta, pb, fill = TRUE)
  pdelta[Var.Delta != 0, ci:=sqrt(Var.Delta) * 1.96][is.na(ci),ci:=0][is.na(Label), Label:=Trait][is.na(Trait_class), Trait_class:="Basis"]
  pdelta[ ci == 0, colours:= "red"][ Trait_class == "IMD", colours:="#26547c"][ Trait_class == "BMK", colours:="#049F76"][ Trait_class == "INF", colours:="#E09D00"][ Trait_class == "CAN", colours:="#F3B8A5"][ Trait_class == "OTH", colours:="black"]

  # Prepare dataset for biplots
  pbchen <- pt[grepl("493_5", Trait)] #  Use Chen 5, rather than basis traits, as landposts.
  pbrest <- pt.viz[ Trait_class != "BC"]
  pbi <- rbind(pbrest, pbchen, fill=TRUE)
  
  observeEvent(input$PCDelta, {
    delta.dt <- pdelta[PC == paste0("PC", input$PCDelta)][order(Delta, decreasing = TRUE)]
    cdata <- session$clientData
    dpheight <- id.height[input$PCDelta]
    output$Delta <- renderPlotly(
      ggplotly(make.delta.plot(delta.dt, input$PCDelta), height = dpheight)
    )
    pc.ptable <- pt[PC == paste0("PC", input$PCDelta)]
    pc.ptable <- pc.ptable[, .(PC, Label, Trait_class, Delta, Var.Delta, P, FDR.PC, stars)]
    output$ptables <- renderDT({ 
      DT::datatable(pc.ptable, escape = F, rownames = F, filter='top', caption = paste0('Projection info for PC', input$PCDelta, '.'), extensions = c("Buttons"), options = list(dom = "Bfrtip", pageLength =10, paging = F, scroller = T, scrollX= T, autoWidth = T,  buttons = list('copy', list(extend = 'csv',text='Download .csv', filename=paste0("Projection_table_PC", input$PCDelta)))))
      })
  })

  output$dstables <- renderDT({
    DT::datatable(qc, escape = F, rownames = F, filter = 'top', autoHideNavigation = F, caption = paste0("General information on the significant (FDR.overall < 1%) projected GWAS summary statistics dataset"), options = list(pagelength = 10, scroller = T, scrollX = T))
  })

  observeEvent(input$b1, {
    if(input$b1 == input$b2){
      if(input$b1 < 14){
        updateSliderInput(inputId = "b1", value = input$b1 + 1)
      } else{
        updateSliderInput(inputId = "b1", value = input$b1 - 1)
      }
    }
  })
  
  observeEvent(input$b2, {
    if(input$b2 == input$b1){
      if(input$b2 < 14){
        updateSliderInput(inputId = "b2", value = input$b2 + 1)
      } else{
        updateSliderInput(inputId = "b2", value = input$b2 - 1)
      }
    }
  })
  
  
  observeEvent(c(input$b1, input$b2), {
    if(input$b1 != input$b2){
    pcx <- paste0("PC", input$b1)
    pcy <- paste0("PC", input$b2)
    pbi2 <- pbi[PC %in% c(pcx, pcy)]
    pbi2 <- data.table::dcast(pbi2, Label + Trait + Trait_class ~ PC, value.var = c("Delta", "stars"))
    setnames(pbi2, old = c(paste0("Delta_", pcx), paste0("Delta_", pcy), paste0("stars_", pcx), paste0("stars_", pcy)), new = c("Delta_x", "Delta_y", "stars_x", "stars_y"))
    pbi2 <- pbi2[ stars_x == "●" | stars_y == "●"]
    output$biplot <- renderPlotly(
      ggplotly(make.biplot(pbi2, pcx, pcy))
    )
  }
  })

 })
