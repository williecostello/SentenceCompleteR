library(data.table)
library(dplyr)
library(quanteda)
library(readr)
library(stringi)

################################################################################
## Functions
################################################################################

## Function to transform/remove non-ASCII characters from data
clean_data <- function(string) {
        string %>% stri_trans_general("latin-ascii") %>% 
                iconv("latin1", "ASCII", sub = "")
}

## Function to build data into corpus & reshape to sentences
corporize <- function(data) {
        data %>% clean_data() %>% corpus() %>% corpus_reshape(to = "sentences")
}

## Function to build N-gram, build feature frequency table, & write to csv
ngrams <- function(num) {
        tokens_num <- tokens_ngrams(data_tokens, n = num)
        freq_table <- dfm(tokens_num) %>% textstat_frequency() %>% setDT()
        write_path <- paste("ngrams/full/ngrams_", i, "_", num, ".csv", sep = "")
        fwrite(freq_table, write_path)
}

################################################################################
## Build 1 to 6-grams for each data chunk
################################################################################

## Set number of chunk files
num_chunks <- 4

for (i in 1:num_chunks) {
        ## Read data chunk
        data_chunk <- read_lines(paste("data/chunk_", i, ".txt", sep = ""))
        
        ## Corporize data
        data_corpus <- corporize(data_chunk)
        
        ## Remove data chunk, as we will now be working only with data corpus
        rm(data_chunk)
        
        ## Tokenize corpus to words, removing punctuation, symbols, numbers, & URLs
        data_tokens <- tokens(data_corpus, remove_punct = TRUE, 
                              remove_symbols = TRUE, remove_numbers = TRUE, 
                              remove_url = TRUE)
        
        ## Remove data corpus, as we will now be working only with tokens
        rm(data_corpus)
        
        ## Build 2- to 6-grams & write feature frequency tables to csv
        for (j in 1:6) { ngrams(j) }
        
        ## Remove data tokens
        rm(data_tokens)
}

## Clean up
rm(clean_data, corporize, ngrams, i, num_chunks)