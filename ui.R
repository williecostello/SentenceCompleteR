library(shiny)
library(shinythemes)

shinyUI(fluidPage(

    theme = shinytheme("lumen"),
    
    tags$head(tags$style("
        #container * {  
            display: inline;
        }")),
        
    titlePanel(
        HTML("SentenceCompleteR. 
             <SMALL>a simple word prediction app</SMALL>"),
        windowTitle = "SentenceCompleteR"
    ),
    
    sidebarLayout(
 
        sidebarPanel(
            textInput("sentence", 
                      h4("Start writing a sentence!"), 
                      value = "It's on the tip of my "),
            "© ", 
            a("Willie Costello", href = "https://github.com/williecostello/"),
        ),

        mainPanel(
            tabsetPanel(type = "tabs",

                tabPanel("App", 
                    br(),
                    div(id = "container", 
                        h3(textOutput("sentence")), 
                        h3(strong(textOutput("topword")))
                    ),
                    br(),
                    tableOutput("topwords"),
                ), 

                tabPanel("Documentation", 
                    h3("Instructions for use"),
                    p("SentenceCompleteR predicts the next word in a sentence based on the last five words typed in. Its top prediction is presented in bold at the top, and its top five predictions are displayed in a table below."),
                    p("Scores for each prediction are also listed in this table, so that one can see how strong its five predictions are, relative to one another. Scores range from 0 to 100; the higher the score, the stronger the prediction."),
                    p("To use, simply type a sentence into the textbox on the left. SentenceCompleteR generates its predictions as you type. However, as predictions take a second or two to compute, you will generally be able to finish typing your sentence before SentenceCompleteR displays its first prediction."),
                    h3("The back end"),
                    div(id = "container",
                        p("SentenceCompleteR's predictions are based on a corpus of blog posts, news stories, and tweets provided by"),
                        a("SwiftKey", href = "https://www.microsoft.com/en-us/swiftkey"),
                        "as part of the",
                        a("Coursera", href = "https://www.coursera.org/"),
                        a("Data Science Specialization", href = "https://www.coursera.org/specializations/jhu-data-science"),
                        "capstone course.",
                        p("All scripting for SentenceCompleteR was completed in R, relying primarily on the"),
                        a(code("quanteda"), href = "https://quanteda.io/"),
                        "and",
                        a(code("data.table"), href = "https://rdatatable.gitlab.io/data.table/"),
                        "packages. Full scripts can be found on my",
                        a("Github.", href = "https://github.com/williecostello/SentenceCompleteR"),
                    ),
                )
            )
        )
    )
))