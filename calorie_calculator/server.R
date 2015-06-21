library(shiny)
library(googleVis)

# TDEE is a function that calculates total daily energy expenditure (TDEE). It first
# calculates the basal metabolic rate (BMR) using age, height and weight with
# appropriate unit conversions. Then it adjusts the BMR for gender and calculates
# the TDEE based on the selected activity level.
TDEE <- function(units, gender, age, height, weight, activity) {
      if(units == "1"){
            genderless_BMR <- (10 * weight * 0.453592) + (6.25 * height * 2.54) - (5 * age)
      }
      else if(units == "2") {
            genderless_BMR <- (10 * weight) + (6.25 * height) - (5 * age)
      }
      else {
            stop("Please select units.")
      }
         
      if(gender == "male") {
            BMR <- genderless_BMR + 5
      }
      else if(gender == "female") {
            BMR <- genderless_BMR - 161
      }
      else {
            stop("Please select a gender.")
      }
      
      if(activity == "sedentary") {
            TDEE <- round(BMR * 1.2)
      }
      else if(activity == "light") {
            TDEE <- round(BMR * 1.375)
      }
      else if(activity == "moderate") {
            TDEE <- round(BMR * 1.55)
      }
      else if(activity == "very active") {
            TDEE <- round(BMR * 1.725)
      }
      else if(activity == "extra active") {
            TDEE <- round(BMR * 1.9)
      }
      else {
            stop("Please select activity level.")
      }
}

shinyServer(
      function(input, output) {
            
            # Create a table that keeps track of the user inputs
            output$variable_table <- renderDataTable({
                  variables <- data.frame(Gender = input$gender,
                                          Age = input$age,
                                          Height = 0,
                                          Weight = 0,
                                          Activity = input$activity)
                  
                  if(input$units == "1") {
                        variables$Height <- input$height_in
                        variables$Weight <- input$weight_lb
                  }
                  else if(input$units == "2") {
                        variables$Height <- input$height_cm
                        variables$Weight <- input$weight_kg
                  }
                  else {
                        variables$Height <- "Invalid unit selection"
                        variables$Weight <- "Invalid unit selection"
                  }
                  variables},
                  options=list(pageLength = 5,    # initial number of records
                               searching = 0,     # global search box on/off
                               info = 0,          # information on/off (how many records filtered, etc)
                               ordering = 0,
                               paging = 0)
            )
            
            # Calculate TDEE when 'Calculate' button is clicked
            TDEE_value <- eventReactive(input$calculate, {
                  if(input$units == "1") {
                        TDEE(input$units,
                            input$gender,
                            input$age,
                            input$height_in,
                            input$weight_lb,
                            input$activity)
                  }
                  else if(input$units == "2") {
                        TDEE(input$units, 
                              input$gender,
                              input$age,
                              input$height_cm,
                              input$weight_kg,
                              input$activity)
                  }
                  else { NULL }
                        
            })
            
            # Create output text for the TDEE value
            output$TDEEvalue <- renderText({paste("Your total daily energy expenditure (TDEE) is",
                                                 TDEE_value(),
                                                 "calories.")
            })
            
            # Create output test for calories needed to lose 1 lb per week
            output$lose_1_lb_wk <- renderText({paste("Diet Plan 1: To lose 1 lb (0.45 kg) per week, you need to consume",
                                                  TDEE_value() - 500,
                                                  "calories per day.")
            })
            
            # Create output test for calories needed to lose 2 lbs per week
            output$lose_2_lb_wk <- renderText({paste("Diet Plan 2: To lose 2 lbs (0.91 kg) per week, you need to consume",
                                                     TDEE_value() - 1000,
                                                     "calories per day.")
            })
            
            # Create output test for calories needed based on caloric deficit of 20% TDEE
            output$ideal_cal_deficit <- renderText({paste("Diet Plan 3: Based on your ideal calorie deificit of",
                                                     round(TDEE_value() * 0.20),
                                                     "calories, you need to consume",
                                                     round(TDEE_value() * 0.80),
                                                     "calories per day.")
            })
            
            # Create a data frame of calories in vs. weight when 'Calculate' button is clicked
            cal_vs_weight_df <- eventReactive(input$calculate, {
                  if(input$units == "1") {
                        weight <- 50:500
                        TDEE <- TDEE(input$units,
                                     input$gender,
                                     input$age,
                                     input$height_in,
                                     50:500,
                                     input$activity)                      
                  }
                  else if(input$units == "2") {
                        weight <- seq(from = 25, to = 225, by = 0.5)
                        TDEE <- TDEE(input$units, 
                                     input$gender,
                                     input$age,
                                     input$height_cm,
                                     weight,
                                     input$activity)
                  }
                  else{ NULL }
                  
                  Lose1lb = TDEE - 500
                  Lose2lb = TDEE - 1000
                  IdealDeficit = round(TDEE * 0.80)
                  
                  cal_vs_weight <- data.frame(Weight = weight,
                                              "Maintenance" = TDEE,
                                              "Lose 1 lb/week" = Lose1lb,
                                              "Lose 2 lb/week" = Lose2lb,
                                              "Based on Ideal Deficit" = IdealDeficit,
                                              check.names = FALSE)
            })
            
            # Create a plot of calories in vs. weight
            output$Weight_TDEE_plot <- renderGvis({
                  plot <- gvisAreaChart(cal_vs_weight_df(),
                                        xvar = "Weight",
                                        yvar = c("Maintenance",
                                               "Lose 1 lb/week",
                                               "Lose 2 lb/week",
                                               "Based on Ideal Deficit"),
                                        options = list(height = 400,
                                                       width = 700,
                                                       chartArea = "{width: '75%'}",
                                                       vAxes = "[{title:'Calories',
                                                                  format:'#,###',
                                                                  textPosition: 'out'}]",
                                                       hAxes = "[{title:'Weight',
                                                                  textPosition: 'out'}]",
                                                       legend = "{position: 'top'}",
                                                       areaOpacity = 0.3,
                                                       focusTarget = 'category'))
                  
            })
      }
)