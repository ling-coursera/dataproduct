library(dplyr)
library(googleVis)
library(shiny)

## download hospital charge data
if (!file.exists("./healthcare-costs.csv")) {
    download.file("http://data.cms.gov/api/views/97k6-zzx3/rows.csv?accessType=DOWNLOAD",
                destfile="./healthcare-costs.csv")
}

## load the data
services <- read.csv("./healthcare-costs.csv", stringsAsFactors=FALSE)

## summarize hospital charges for each service in every state
services <- group_by(services, DRG.Definition, Provider.State)
services$Average.Covered.Charges <- as.numeric(sub("\\$", "", services$Average.Covered.Charges))

## summary statistics: standard deviation, median, max, min
services <- summarize(services, Standard.Deviation = round(sd(Average.Covered.Charges)),
                                Median = round(median(Average.Covered.Charges)),
                                Max = round(max(Average.Covered.Charges)), 
                                Min = round(min(Average.Covered.Charges)))

## set standard deviation to zero for the single hospital for a service in a state
services$Standard.Deviation[is.na(services$Standard.Deviation)] <- 0

## tooltip text shows the range of hospital charges
services$tooltip <- paste(services$Provider.State, ": $", services$Min, " - $", services$Max, sep="")

## 
## Utility function for identifying top n most common inpatient services
##
topServices <- function(costs, n) {
    ## calcuate total usage for each service
    services <- group_by(costs, DRG.Definition)
    services <- summarize(services, Usage = sum(Total.Discharges))
    
    ## sort the services in descending order of usage
    services <- arrange(services, desc(Usage))
    head(services, n)
}

shinyServer(
    function(input, output) {
        ## get the selected measure
        myMeasure <- reactive({
            input$Measure
        })
        
        ## get the selected service
        myService <- reactive({
            input$Service
        })
        
        ## get the service name for the selected service
        myServiceName <- reactive({
            switch(input$Service,
                   "Major joint replacement or reattachment"="470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC",
                   "Septicemia or severe sepsis"="871 - SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC",
                   "Esophagitis, gastroent & misc digest disorders"="392 - ESOPHAGITIS, GASTROENT & MISC DIGEST DISORDERS W/O MCC",
                   "Heart failure & shock"="292 - HEART FAILURE & SHOCK W CC",
                   "Kidney & urinary tract infections"="690 - KIDNEY & URINARY TRACT INFECTIONS W/O MCC",
                   "Simple pneumonia & pleurisy"="194 - SIMPLE PNEUMONIA & PLEURISY W CC",
                   "Heart failure & shock with complicatons"="291 - HEART FAILURE & SHOCK W MCC",
                   "Misc disorders of nutrition,metabolism,fluids/electrolytes"="641 - MISC DISORDERS OF NUTRITION,METABOLISM,FLUIDS/ELECTROLYTES W/O MCC",                            "Renal failure"="683 - RENAL FAILURE W CC",
                   "Chronic obstructive pulmonary disease"="190 - CHRONIC OBSTRUCTIVE PULMONARY DISEASE W MCC")
        })
        
        ## title of the GeoChart
        output$service <- renderText({
            switch(myMeasure(),
                   "Median" = paste("Median charge($) for ", input$Service),
                   "Standard.Deviation" = paste("Variation of charges($), measured by standard deviation, for ", input$Service))
        })        
        
        ## GeoChart showing variation of hospital charges 
        output$gvis <- renderGvis({
            ## get the charge data for the selected service
            selectedService <- subset(services, DRG.Definition == myServiceName())
            
            gvisGeoChart(selectedService,
                         locationvar="Provider.State", colorvar=myMeasure(), hovervar="tooltip",
                         options=list(region="US", displayMode="regions",
                                      resolution="provinces",
                                      colorAxis="{colors: ['#FFFFFF', 'red']}",
                                      width=500, height=400
                         ))
        })
    }
)