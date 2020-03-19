################################################################################
## Load required packages
################################################################################

library(data.table)
library(dplyr)
library(stringr)

################################################################################
## Get N-gram score tables & input
################################################################################

file_list <- paste("scores/", list.files("scores/"), sep = "")
scores <- list()
scores <- lapply(file_list, fread)

################################################################################
## Function to generate list of top five next words based on input string
################################################################################

find_next <- function(input) {
                
################################################################################
## Format input string & generate search strings
################################################################################
        
        ## Convert input to lowercase & remove punctuation, digits, multispaces 
        search <- input %>% str_to_lower() %>% str_remove_all("[[:punct:]]") %>% 
                str_remove_all("[[:digit:]]") %>% 
                str_replace_all("[\\s]+", " ") %>% str_remove_all("^[\\s]")
        ## Add space to end of string, if not already present 
        if (grepl("\\s$", search) == FALSE) { 
                search <- paste(search, " ", sep = "") }
        ## Check to see if at least 1 word has been input
        if (search == " ") { 
                stop("Please enter a valid sentence.") 
        }

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
## 3. Search score tables & grab top five search string completions
################################################################################

        search <- rev(search)
        allwords <- data.table()
        for (i in words:1) {
                allwords <- na.omit(rbind(allwords, 
                                          scores[[i]]
                                          [ngram %like% search[i]][1:5, ]))
        }
        
        ## Check to see that at least 1 completion has been found
        if (nrow(allwords) == 0) {
                stop("No predictions found.")
        }
        
################################################################################
## 4. Generate full list of top words & order by score
################################################################################
        
        topwords <- setorder(allwords, -score)
        ## Shorten strings to last word only
        for (i in 1:nrow(topwords)) {
                ngram <- topwords[i, 1]
                topwords[i, 1] <- gsub(ngram, pattern = "[[:alpha:]]*_", 
                                       replacement = "")
        }
        
################################################################################
## 5. Delete repetitions & return top five list
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
        topfive <- na.omit(topfive[1:5, .("Top 5 Predictions" = ngram, 
                                          Score = score * 100)])
        return(topfive)
}
