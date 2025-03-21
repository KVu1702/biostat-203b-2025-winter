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
          p("Numerical and graphical summaries of the MIMIC IV ICU Cohort."),
          selectInput('Variables', 'Select variable:', choices = c("(Select)", 
            "Race", "Insurance", "Marital Status", "Gender", "Age intime",
            "Lab Events","Chart Events"
            ), 
          width = "100%", selected = "(Select)"),
          width = "100%", height = "100%",
          tableOutput("cohort_summary_table"),
          plotOutput("cohort_summary_plot"))
        ),
      tabItem("patient",
        box(
          title = "MIMIC IV ICU Patient Summary",
          p("Patient ADT and ICU Stay Information"),
          selectizeInput("Patient_ID", "Type Patient ID",
            choices = NULL, 
            multiple = FALSE, 
            options = list(placeholder = "Type"),
            width = "100%"),
          width = "100%", height = "100%",
          plotOutput("ADT_summary_plot"),
          plotOutput("ICU_sumamry_plot")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  #Creating the cohort summary plots and numerical summaries
  output$cohort_summary_plot <- renderPlot({
    
    variable <- gsub(" ", "_", tolower(input$Variables))
    
    #Demographic information
    if (variable == "age_intime") {
      mimic_icu_cohort %>%
        ggplot(aes(x = age_intime)) +
        geom_boxplot(outlier.shape = NA) +
        labs(title = "Age at Intime Box and Whisker Plot",
             x = "Age") +
        theme(axis.title.y = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank())
    }
    else if (variable == "race") {
      mimic_icu_cohort %>%
        count(race) %>%
        ggplot(mapping = aes(x = n, y = race)) +
        geom_bar(stat = "identity") +
        labs(title = "Race Barplot",
             x = "Frequency",
             y = "Race") +
        theme(axis.text.y=element_text(size=10))
    }
    else if (variable == "insurance") {
      mimic_icu_cohort %>%
        count(insurance) %>%
        ggplot(mapping = aes(x = n, y = insurance)) +
        geom_bar(stat = "identity") +
        labs(title = "Insurance Barplot",
             x = "Frequency",
             y = "Insurance") +
        theme(axis.text.y=element_text(size=10))
    }
    else if (variable == "marital_status") {
      mimic_icu_cohort %>%
        count(marital_status) %>%
        ggplot(mapping = aes(x = n, y = marital_status)) +
        geom_bar(stat = "identity") +
        labs(title = "Marital Status Barplot",
             x = "Frequency",
             y = "Marital Status") 
    }
    else if (variable == "gender") {
      mimic_icu_cohort %>%
        count(gender) %>%
        ggplot(mapping = aes(x = n, y = gender)) +
        geom_bar(stat = "identity") +
        labs(title = "Gender Barplot",
             x = "Frequency",
             y = "Gender") 
    }
    else if (variable == "lab_events") {
      mimic_icu_cohort %>%
        ggplot() +
        geom_boxplot(aes(x = sodium, y = "Sodium"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = hematocrit, y = "Hematocrit"),
                     outlier.shape = NA) +
        geom_boxplot(aes(x = bicarbonate, y = "Bicarbonate"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = chloride, y = "Chloride"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = wbc, y = "White Blood Cells"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = potassium, y = "Potassium"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = glucose, y = "Glucose"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = creatinine, y = "Creatinine"), 
                     outlier.shape = NA) +
        labs(title = "Lab Event Values",
             x = "Values",
             y = "Lab Event") +
        xlim(0, 300)
    }
    else if (variable == "chart_events") {
      mimic_icu_cohort %>%
        ggplot() +
        geom_boxplot(aes(x = non_invasive_blood_pressure_diastolic, 
                         y = "NBPd"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = temperature_fahrenheit, y = 
                           "Temperature (Fahrenheit"),
                     outlier.shape = NA) +
        geom_boxplot(aes(x = non_invasive_blood_pressure_systolic, 
                         y = "NBPs"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = respiratory_rate, y = "RR"), 
                     outlier.shape = NA) +
        geom_boxplot(aes(x = heart_rate, y = "HR"), 
                     outlier.shape = NA) +
        labs(title = "Chart Event Values",
             x = "Values",
             y = "Lab Event") +
        xlim(0, 200)
    }
    }
  )
  
  output$cohort_summary_table <- renderTable({
    
    variable <- gsub(" ", "_", tolower(input$Variables))
    
    #Demographic information
    if (variable == "age_intime") {
      res <- rbind(summary(mimic_icu_cohort$age_intime))
      rownames(res) <- c(
        "Age at in time"
      )
      as.data.frame(res)
    }
    else if (variable == "race") {
      mimic_icu_cohort %>%
        count(race)
    }
    else if (variable == "insurance") {
      mimic_icu_cohort %>%
        count(insurance)
    }
    else if (variable == "marital_status") {
      mimic_icu_cohort %>%
        count(marital_status)
    }
    else if (variable == "gender") {
      mimic_icu_cohort %>%
        count(gender)
    }
    else if (variable == "lab_events") {
      res <- rbind(
        summary(mimic_icu_cohort$hematocrit),
        summary(mimic_icu_cohort$respiratory_rate),
        summary(mimic_icu_cohort$bicarbonate),
        summary(mimic_icu_cohort$chloride),
        summary(mimic_icu_cohort$wbc),
        summary(mimic_icu_cohort$creatinine),
        summary(mimic_icu_cohort$glucose),
        summary(mimic_icu_cohort$potassium)
        )
      rownames(res) <- c(
        "Hematocrit",
        "Sodium",
        "Bicarbonate",
        "Chloride",
        "White blood cells",
        "Creatinine",
        "Glucose",
        "Potassium"
      )
      as.data.frame(res)
    }
    else if (variable == "chart_events") {
      res <- rbind(
        summary(mimic_icu_cohort$temperature_fahrenheit),
        summary(mimic_icu_cohort$respiratory_rate),
        summary(mimic_icu_cohort$non_invasive_blood_pressure_diastolic),
        summary(mimic_icu_cohort$non_invasive_blood_pressure_systolic),
        summary(mimic_icu_cohort$heart_rate)
      )
      rownames(res) <- c(
        "Temperature Fahrenheit",
        "Respiratory Rate",
        "Diastolic Non-invasive Blood Pressure",
        "Systolic Non-invasive Blood Pressure",
        "Heart Rate"
      )
      as.data.frame(res)
    }
  }, rownames = TRUE
  )
  
  #Dynamic loading of patient IDs
  observe({
    updateSelectizeInput(session, "Patient_ID", 
                         choices = mimic_icu_cohort$subject_id, 
                         server = TRUE)
  })

  #Creating the patient ADT and ICU stay chart
  output$ADT_summary_plot <- renderPlot({
    
    req(input$Patient_ID)
    #Setting our patient ID
    ID <- as.numeric(input$Patient_ID)
    
    #Loading the required dataframes from BigQuery
    
    #Reading in admissions to get race information
    admissions_tbl <- tbl(con_bq, "admissions") %>% 
      filter(subject_id %in% ID) %>%
      collect()
    subject_race <- tolower(unique(admissions_tbl$race))
    
    #Reading in patients to get gender and age information
    patients_tbl <- tbl(con_bq, "patients") %>% 
      filter(subject_id %in% ID) %>%
      collect()
    subject_gender <- unique(patients_tbl$gender)
    subject_age <- unique(patients_tbl$anchor_age)
    
    #Creating the title for the graph
    subject_title <- paste0("Patient ", ID, ", ", 
                            subject_gender, ", ", 
                            subject_age, ", years old, ", 
                            subject_race)
    
    #Reading in and joining diagnoses and d_icd_diagnoses 
    #to get the top three diagnoses for the subtitle
    
    diagnoses_icd_tbl <- tbl(con_bq, "diagnoses_icd") %>% 
      arrange(subject_id, hadm_id, seq_num, icd_code ) %>% 
      filter(subject_id %in% ID) %>% 
      head(3) %>%
      collect()
    d_icd_diagnoses_tbl <- tbl(con_bq, "d_icd_diagnoses") %>%
      collect()
    joined_diagnoses_tbl <- left_join(diagnoses_icd_tbl, d_icd_diagnoses_tbl, 
                                      by = "icd_code") 
    top_three_diagnoses <- joined_diagnoses_tbl$long_title
    subject_subtitle <- paste0(top_three_diagnoses[1], "\n", 
                               top_three_diagnoses[2], "\n", 
                               top_three_diagnoses[3])
    
    
    #Reading in and joining procedures and icd_procedures to get procedure of 
    #patient and the procedure ID
    d_icd_procedures_tbl <- tbl(con_bq, "d_icd_procedures") %>%
      collect()
    procedures_icd_tbl <- tbl(con_bq, "procedures_icd") %>%
      arrange(subject_id, hadm_id, seq_num, icd_code ) %>% 
      filter(subject_id %in% ID) %>%
      collect()
    joined_procedures_tbl <- left_join(procedures_icd_tbl, 
                                       d_icd_procedures_tbl, 
                                       by = "icd_code") %>% 
      select(all_of(c("chartdate", "long_title"))) %>%
      rename("Calender_Time" = chartdate) %>%
      mutate(type = "Lab") 
    
    #Reading in labevents 
    labevents_tbl <- tbl(con_bq, "labevents") %>% 
      #Filering based on subject ID
      filter(subject_id %in% ID) %>%
      #Selecting only on columns of interest
      select(all_of(c("subject_id", "charttime"))) %>%
      #Renaming charttime to Calender_Time
      rename("Calender_Time" = charttime) %>%
      collect()
    #Converting time to UTC and not PDT
    labevents_tbl$Calender_Time <- as.POSIXct(labevents_tbl$Calender_Time, 
                                              tz="UTC")
    
    #Reading in transfers
    transfers_tbl <- tbl(con_bq, "transfers") %>% 
      filter(subject_id %in% ID) %>% 
      #Filtering out values where care units is UNKNOWN
      filter(careunit != "UNKNOWN") %>% 
      select(all_of(c("subject_id", "intime", "outtime", "careunit"))) %>%
      collect()
    transfers_tbl$intime <- as.POSIXct(transfers_tbl$intime, tz = "UTC")
    transfers_tbl$outtime <- as.POSIXct(transfers_tbl$outtime, tz = "UTC")
    
    #Filtering transfers by ICU/CCU
    transfers_ICU_CCU_tbl <- transfers_tbl %>% 
      filter(grepl('ICU|CCU', careunit)) %>%
      mutate(ICU_CCU = "Yes")
    transfers_Not_ICU_CCU_tbl <- transfers_tbl %>% 
      filter(!(grepl('ICU|CCU', careunit))) %>%
      mutate(ICU_CCU = "No")
    
    #Joining resulting dataframes into 1
    res_df_tbl <- bind_rows(
      labevents_tbl %>% mutate(type = "Lab"),
      joined_procedures_tbl %>% mutate(type = "Procedure"),
      transfers_ICU_CCU_tbl %>% mutate(type = "ADT"),
      transfers_Not_ICU_CCU_tbl %>% mutate(type = "ADT")
    ) %>% 
      mutate(long_title = str_wrap(long_title, 15)) %>% 
      mutate(careunit = str_wrap(careunit, 15))
    
    #Define line segment size
    segment_size = 2
    
    ggplot() + 
      #Plotting the ADT Data (Not ICU/CCU)
      geom_segment(data = res_df_tbl %>% 
                     filter((type == "ADT") & (ICU_CCU == "No")), 
                   aes(x = intime, y = type, xend = outtime, yend = type, 
                       color = careunit), linewidth = segment_size) +
      #Plotting the ADT Data (ICU/CCU)
      geom_segment(data = res_df_tbl %>% 
                     filter((type == "ADT") & (ICU_CCU == "Yes")), 
                   aes(x = intime, y = type, xend = outtime, yend = type, 
                       color = careunit), linewidth = segment_size*3) +
      #Plotting the Lab data
      geom_point(data = res_df_tbl %>% filter(type == "Lab"), 
                 aes(x = Calender_Time, y = type), shape = 3, size = 5) +
      #Plotting the Procedure data
      geom_point(data = res_df_tbl %>% filter(type == "Procedure"), 
                 aes(x = Calender_Time, 
                     y = type, 
                     shape = long_title), size = 5) +
      theme(
        axis.title.y = element_blank(),
        legend.position = "bottom",
        legend.box = "vertical"
      ) + 
      scale_y_discrete(limits = rev) +
      xlab("Calender Time") + 
      labs(title = subject_title,
           subtitle = subject_subtitle,
           color = "Care Unit", 
           shape = "Procedure") +
      guides(color = guide_legend(order = 1),
             shape = guide_legend(order = 2))
    
  })
  
  output$ICU_sumamry_plot <- renderPlot({
    req(input$Patient_ID)
    #Setting our patient ID
    ID <- as.numeric(input$Patient_ID)
    
    #Reading in icustays.csv.gz
    icustays_tbl <- tbl(con_bq, "icustays") %>%
      collect()
    
    subset_itemid <-c(220045, 220180, 220179, 223761, 220210)
    
    chartevents_tbl <- tbl(con_bq, "chartevents") %>% 
      #Filering based on subject ID
      filter(subject_id %in% ID) %>%
      #Subset based on needed measurements
      filter(itemid %in% subset_itemid) %>%
      #Sorting our values
      arrange(itemid, charttime) %>%
      collect()
    #Converting time to UTC and not PDT
    chartevents_tbl$charttime <- as.POSIXct(chartevents_tbl$charttime, 
                                            tz = "UTC")
    
    
    #We left join chartevents and icustays by stay_id to differentiate the unique
    #icu stays for each measurement
    joined_icu_chart_tbl <- left_join(chartevents_tbl, 
                                      icustays_tbl, 
                                      by = "stay_id")
    
    #We rename the item_id with their abbreviations by utilizing d_items.csv.gz
    d_items_tbl <- tbl(con_bq, "d_items") %>% 
      collect()
    #We left join with our chart events on itemid
    joined_icu_chart_tbl <- left_join(joined_icu_chart_tbl, 
                                      d_items_tbl, 
                                      by = "itemid") 
    
    
    #Creating our title
    subject_title <- paste0("Patient ", ID, ", ICU stays - Vitals")
    
    #Note, our y is value and not valuenum, we want the values to be a double
    #and not a string
    ggplot(joined_icu_chart_tbl, mapping = aes(x = charttime, y = valuenum, 
                                               color = abbreviation, 
                                               group = abbreviation)) +
      geom_point() +
      geom_line() +
      facet_grid(abbreviation~stay_id, scales = "free", space = "fixed") +
      scale_x_datetime(guide = guide_axis(n.dodge = 2)) + 
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        legend.position = "none"
      ) + 
      labs(title = subject_title)
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
