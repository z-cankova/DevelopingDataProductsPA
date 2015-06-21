library(shiny) 

shinyUI(pageWithSidebar(
      headerPanel("Calorie Calculator"),
      sidebarPanel(
            radioButtons("units",
                         label = h4("Select units:"),
                         choices = list("US" = 1,
                                        "Metric" = 2),
                         selected = 1),
            
            selectizeInput("gender", label = h5("Select gender"), 
                           choices = list("Male" = "male",
                                          "Female" = "female"),
                           options = list(placeholder = 'Please select an option below',
                                          onInitialize = I('function() { this.setValue(""); }'))),
            
            numericInput("age", "Age", NULL, min = 1, max = 120, step = 1),
            
            conditionalPanel(
                  condition = "input.units == 1",
                  numericInput("height_in", "Height in inches", NULL, min = 1, max = 120, step = 1),
                  numericInput("weight_lb", "Weight in lb", NULL, min = 1, max = 1100, step = 1)
            ),

            conditionalPanel(
                  condition = "input.units == 2",
                  numericInput("height_cm", "Height in cm", NULL, min = 1, max = 300, step = 1),
                  numericInput("weight_kg", "Weight in kg", NULL, min = 1, max = 500, step = 1)
            ),
            
            selectizeInput("activity", label = h5("Select activity level"), 
                        choices = list("Sedentary (little or no exercise)" = "sedentary",
                                       "Lightly active (light exercise 1-3 days/week)" = "light",
                                       "Moderately active (moderate exercise 3-5 days/week)" = "moderate",
                                       "Very active (hard exercise 6-7 days/week)" = "very active",
                                       "Extra active (very hard exercise and physical job or 2x exercise/day)" = "extra active"),
                        options = list(placeholder = 'Please select an option below',
                                       onInitialize = I('function() { this.setValue(""); }'))),
                        
            actionButton("calculate", "Calculate")
      ),
      mainPanel(
            h3("Personalized Daily Calorie Requirements"),
            
            p("This is a calculator that can help you determine how much energy you use
              up daily (know as the TDEE), and the corresponding calories you need to eat
              to maintain your weight. To begin, please fill out the information in the
              left panel and click 'Calculate'."),
            
            dataTableOutput(outputId = "variable_table"),
            tags$style(type="text/css", "#variable_table tfoot {display:none;}"),
            
            h4(textOutput("TDEEvalue")),
            
            p("To lose weight, you need to follow one simple rule: you need to eat less
              calories than you burn. Taking the difference between the calories you eat and
              those you burn will produces your calorie deficit. By creating a 500 calorie
              deficit each day, you can lose 1 lb per week. For you this means:"),
            
            h5(textOutput("lose_1_lb_wk")),
            h5(textOutput("lose_2_lb_wk")),
            
            p("This method is relatively simple, but it can result in very low calorie
              consumption values, and can make dieting difficult to manage. A more effective
              method is set your calorie deficit to 20% of your TDEE. This allows you
              to adjust for your current weight and maximize fat loss, while minimizing
              muscle loss. For you this means:"),
            
            h5(textOutput("ideal_cal_deficit")),
            
            p("Below is an interactive chart that shows you your daily calorie allowance
              based on your current weight. It includes the calories you need to
              maintain your weight, as well as those based on the diet plans mentioned above.
              Drag your mouse cursor over the chart to view calorie intake estimates
              for the different diet plans at each weight."),
            
            htmlOutput("Weight_TDEE_plot"),
            
            p("You can see that when the daily allowance is based on the ideal calorie
              deficit, the resulting calories remain above 1000 even at lower weights.
              This ensures that muscle loss is minimized."),
            
            h3("References"),
            
            p("The TDEE calculations are based on the Mifflin-St Jeor formula used to obtain
              the basal metabolic rate, and then adjusted by a factor depending on
              activity level. The infomation for these calculations was obtained from the
              following web sites:"),
            
            a("http://www.calculator.net/calorie-calculator.html",
              href = "http://www.calculator.net/calorie-calculator.html"),
            br(),
            a("http://www.freedieting.com/calorie_needs.html",
              href = "http://www.freedieting.com/calorie_needs.html"),
            br(),
            a("http://www.bmi-calculator.net/bmr-calculator/harris-benedict-equation/",
              href = "http://www.bmi-calculator.net/bmr-calculator/harris-benedict-equation/"),
            p(""),
            
            p("Calculations of calorie deficits are based on information from the following
              web pages:"),
            
            a("http://www.acaloriecounter.com/diet/how-many-calories-should-i-eat-per-day-to-lose-weight/",
              href = "http://www.acaloriecounter.com/diet/how-many-calories-should-i-eat-per-day-to-lose-weight/"),
            br(),
            a("http://www.acaloriecounter.com/diet/calorie-deficit-to-lose-weight/",
              href = "http://www.acaloriecounter.com/diet/calorie-deficit-to-lose-weight/"),
            br(),
            
            p("")
      ) 
))