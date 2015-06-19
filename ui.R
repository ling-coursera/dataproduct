library(shiny)

shinyUI(pageWithSidebar(
    
    ## Application title
    headerPanel("Hospital Charges for Top Inpatient Services in U.S."),
    
    ## user inputs
    sidebarPanel(
        radioButtons("Measure", "Select a type of analysis:",
                     choices = c("Median charge in a state"="Median", 
                                 "Variation of charges within a state"="Standard.Deviation")),
        
        selectInput("Service", "Select one of top 10 most common inpatient services:", 
                    choices = c("Major joint replacement or reattachment",
                                "Septicemia or severe sepsis",
                                "Esophagitis, gastroent & misc digest disorders",
                                "Heart failure & shock",
                                "Kidney & urinary tract infections",
                                "Simple pneumonia & pleurisy",
                                "Heart failure & shock with complicatons",
                                "Misc disorders of nutrition,metabolism,fluids/electrolytes",
                                "Renal failure",
                                "Chronic obstructive pulmonary disease"))
    ),
    
    mainPanel(
        tabsetPanel("tab",
            ## analysis results
            tabPanel("Hospital Charges",
                ## Geochart title
                h3(textOutput("service")),

                ## GeoChart showing variation of hospital charges
                htmlOutput("gvis")
            ),
            ## help documentation
            tabPanel("Help", 
                     h4('This web app shows hospital charges for top 10 most common inpatient services across the United States.'),
                     br(),
                     h4('First, select type of analysis, median charge in a state or variation of charges within a state.
                         Next select one of the 10 most common inpatient services.'),
                     br(),
                     h4('A U.S. map is then shown, with individual states colored by its median charge or standard deviation of charges.
                         Hovering over a state shows the range of the charges in that state, in addition to the 
                         median/standard deviation.')
            )
        )
    )
    
))