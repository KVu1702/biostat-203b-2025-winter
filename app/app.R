#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

#Importing in required libraries for RShiny
library(shiny)
library(shinydashboard)


#Importing in required libraries for dataset generation
library(bigrquery)
library(dbplyr)
library(DBI)
library(gt)
library(gtsummary)
library(tidyverse)

#Reading in the mimic ICU cohort tab 1
mimic_icu_cohort <- readRDS(
  "~/biostat-203b-hw/hw4/mimiciv_shiny/mimic_icu_cohort.rds"
  )

#Connecting to the database
# path to the service account token 
satoken <- "biostat-203b-2025-winter-4e58ec6e5579.json"
# BigQuery authentication using service account
bq_auth(path = satoken)

# connect to the BigQuery database `biostat-203b-2025-mimiciv_3_1`
con_bq <- dbConnect(
  bigrquery::bigquery(),
  project = "biostat-203b-2025-winter",
  dataset = "mimiciv_3_1",
  billing = "biostat-203b-2025-winter"
)

# Connecting to the required databases to create the graph in tab 2

# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = "MIMIC IV"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Cohort Summary", tabName = "summary", icon = icon("chart-bar")),
      menuItem("Patient Details", tabName = "patient", icon = icon("user"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem("summary",
        box(
          title = "MIMIC IV ICU Cohort Summary",
          p("Numerical and graphical summaries of the MIMIC IV ICU Cohort by 
          long stays (>= 2 days = True and < 2 days = False)"),
          selectizeInput('Variables', 'Select variable:', choices = 
          c("(Select)", mimic_icu_cohort$table_body$var_label)), 
          width = 12,
          gt_output(outputId = "gt_MIMIC")
          )
        ),
      tabItem("patient"
      )
    )
  )
)


server <- function(input, output) {
  
  output$gt_MIMIC <- render_gt(
    mimic_icu_cohort |> 
      modify_table_body(~ filter(.x, var_label == input$Variables))|>
    as_gt()
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
