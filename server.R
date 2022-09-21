
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  pt = fread("data/PT_sig_202208.tsv")
  qc = fread("data/QC_sig_202208.tsv")
  pb = fread("data/pbasis_202208.tsv")
  pt.viz = pt[!Trait %in% c("M13_GOUT_FinnGen_FinnGenR7_1", "K11_UC_STRICT2_FinnGen_FinnGenR7_1", "FG_DISVEINLYMPH_FinnGen_FinnGenR7_1", "L12_DERMATITISNAS_FinnGen_FinnGenR7_1")] # Remove redundant traits
  id.height <- c(850, # PC1
                 850, # PC2
                 850, # PC3
                 850, # PC4
                 1500, # PC5
                 850, # PC6
                 850, # PC7
                 2000, # PC8
                 850, # PC9
                 850, # PC10
                 850, # PC11
                 700, # PC12
                 850, # PC13
                 900 # PC14
                 )
  id.height.hm <- c(BC = 1050,
                    BMK = 1100,
                    CAN = 900,
                    IMD = 1600,
                    INF = 700,
                    OTH = 1100
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
  
  # Prepare datasets for heatmaps
  PCorder <- paste0("PC", 1:14)
  hmcol <- rev(colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7", "#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061"))(100))
  
  ## Chen
  pt.chen <- pt[ First_Author == "Chen"][!grepl("Chen_32888493_6", Trait)]
  hmp.chen <- as.data.frame(data.table::dcast(pt.chen[, .(Label, Population, PC, Delta)], Label + Population ~ PC))
  rownames(hmp.chen) <- hmp.chen$Label
  hmp.chen <- hmp.chen[, -1]
  hmp.chen <- hmp.chen[, c("Population", PCorder)]
  hmp.chen$Population <- gsub(pattern = " \\(.*", replacement = "", hmp.chen$Population)
  
  hmp.chen.stars <- as.data.frame(data.table::dcast(pt.chen[, .(Label, PC, stars)], Label ~ PC))
  rownames(hmp.chen.stars) <- hmp.chen.stars$Label
  hmp.chen.stars <- hmp.chen.stars[, -1]
  hmp.chen.stars <- hmp.chen.stars[, PCorder]
  
  
  anc_colours <- c("#F7EF81", "#63a375", "#586994", "#ffab44", "#e86668", "#C5D5EA") # Population colours 
  annchencols <- list(pop = anc_colours[c(3, 5, 1, 2, 4)]) # keep consistency with doughnut plot
  names(annchencols$pop) <- unique(hmp.chen$Population)
  
  # Trait class heatmap
  pt.class <- pt.viz[!grepl("32888493_[1-4,6]", Trait)] # Use Chen Trans-ethnic as a representative of Chen
  
  
  # Prepare outputs
  
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
      ggplotly(make.biplot(pbi2, pcx, pcy), height = 850)
    )
  }
  })
  
  output$hmchen <- renderPlotly({
    heatmaply(hmp.chen[, c(2:15)], 
              Colv = FALSE, 
              limits= c(-max(abs(hmp.chen[, c(2:15)])), max(abs(hmp.chen[, c(2:15)]))), 
              cellnote = hmp.chen.stars, cellnote_textposition="middle center", 
              colors = hmcol, row_side_colors = hmp.chen[ "Population"], row_side_palette = annchencols$pop,
              main = "Projection Heatmap of Chen et al., (2020) blood cells and related traits") %>% 
              layout(height=900)
  })

  
  observeEvent(input$tclass, {
    pt.c <- pt.class[ Trait_class == input$tclass]
    hmp.c <- as.data.frame(data.table::dcast(pt.c[, .(Label, PC, Delta)], Label ~ PC))
    rownames(hmp.c) <- hmp.c$Label
    hmp.c <- hmp.c[, PCorder]
    
    hmp.c.stars <- as.data.frame(data.table::dcast(pt.c[, .(Label, PC, stars)], Label ~ PC))
    rownames(hmp.c.stars) <- hmp.c.stars$Label
    hmp.c.stars <- hmp.c.stars[, PCorder]
    
    output$hmclass <- renderPlotly(
      heatmaply(hmp.c, 
                Colv = FALSE, 
                limits= c(-max(abs(hmp.c)), max(abs(hmp.c))), 
                cellnote = hmp.c.stars, cellnote_textposition="middle center", 
                colors = hmcol, main = paste0("Projection Heatmap for trait class: ", input$tclass)) %>% 
        layout(height=id.height.hm[input$tclass])
    )
  })
  
  
 })
