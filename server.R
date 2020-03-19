library(shiny)
library(data.table)
library(dplyr)
library(stringr)

file_list <- paste("scores/", list.files("scores/"), sep = "")
scores <- list()
scores <- lapply(file_list, fread)

shinyServer(function(input, output) {

    search_string <- reactive({
        
################################################################################
## Format input string & generate search strings
################################################################################
        
        ## Convert input to lowercase & remove punctuation, digits, multispaces 
        search <- input$sentence %>% str_to_lower() %>% 
            str_remove_all("[[:punct:]]") %>% 
            str_remove_all("[[:digit:]]") %>% 
            str_remove_all("[$^]") %>%
            str_remove_all("^[\\s]") %>%
            str_replace_all("[\\s]+", " ")
        ## Add space to end of string, if not already present 
        if (grepl("\\s$", search) == FALSE) { 
            search <- paste(search, " ", sep = "") }
        return(search)
        
    })
    
    find_next <- reactive({
        
        search <- search_string()

        ## Check to see if at least 1 word has been input
        validate(
            need(search != " ", "Please enter a valid sentence.")
        )
        
        ## Count words in search string
        words <- sapply(strsplit(search, " "), length)
        
        ## Trim to last five words
        if (words > 5) { 
            search <- word(search, start = -6, end = -1) 
            words <- 5
        }
        
        ## Add ^ to start of search string
        search <- paste("^", search, sep = "")
        
        ## Convert to score table format
        search <- gsub(search, pattern = " ", replacement = "_")
        
        ## Create vector of search strings
        if (words == 1) { search <- search } else {
            for (i in 2:words) {
                search[i] <- sub(search[i - 1], pattern = "[[:alpha:]]*_", 
                                 replacement = "")
            }
        }
        
################################################################################
## Search score tables & grab top five search string completions
################################################################################
        
        search <- rev(search)
        allwords <- data.table()
        for (i in words:1) {
            allwords <- na.omit(rbind(allwords, 
                                      scores[[i]]
                                      [ngram %like% search[i]][1:5, ]))
        }
        
        validate(
            need(nrow(allwords) != 0, "// No predictions found.")
        )
        
################################################################################
## Generate full list of top words & order by score
################################################################################
        
        topwords <- setorder(allwords, -score)
        ## Shorten strings to last word only
        for (i in 1:nrow(topwords)) {
            ngram <- topwords[i, 1]
            topwords[i, 1] <- gsub(ngram, pattern = "[[:alpha:]]*_", 
                                   replacement = "")
        }
        
################################################################################
## Delete repetitions & return top five list
################################################################################        
        
        topfive <- topwords[1, ]
        for (i in 2:nrow(topwords)) {
            nomatches <- TRUE
            for (j in 1:(i-1)) { 
                if (topwords[i, 1] != topwords[j, 1]) {
                    nomatches <- c(nomatches, TRUE)
                } else {
                    nomatches <- c(nomatches, FALSE)
                }
            }
            if (all(nomatches) == TRUE) {
                topfive <- rbind(topfive, topwords[i, ])
            }
        }
        topfive <- na.omit(topfive[1:5, .("Top 5 Predictions" = ngram, Score = score * 100)])
        return(topfive)
        
    })

    output$sentence <- renderText ( input$sentence )
    
    output$topword <- renderText ( as.character(find_next()[1, 1]) )
    
    output$topwords <- renderTable (
        find_next(),
        striped = TRUE, 
        hover = FALSE,
        bordered = FALSE, 
        width = 250
    )

})