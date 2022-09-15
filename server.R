
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

  observeEvent(input$PCDelta, {
    delta.dt <- pdelta[PC == paste0("PC", input$PCDelta)][order(Delta, decreasing = TRUE)]
    cdata <- session$clientData
    dpheight <- id.height[input$PCDelta]
    output$Delta <- renderPlotly(
      ggplotly(make.delta.plot(delta.dt, input$PCDelta), height = dpheight),
    )
    pc.ptable <- pt[PC == paste0("PC", input$PCDelta)]
    pc.ptable <- pc.ptable[, .(PC, Label, Trait_ID_2.0, Delta, Var.Delta, P, FDR.PC, stars)]
    output$ptables <- renderDT({ 
      DT::datatable(pc.ptable, escape = F, extensions = c("Buttons"), options = list(dom = "Bfrtip", pageLength =15),rownames = F, filter='top') # CONTINUE HERE. ADD Download buttons and figure how to compress numbers and column widths
      })
  })


  
  
})
