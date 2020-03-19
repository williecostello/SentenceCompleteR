library(data.table)
library(dplyr)

## Set number of chunk files to combine
num_chunks <- 2

for (i in 1:6) {
        ## Grab list of N-gram frequency table chunk files
        file_list <- paste("ngrams/full_trim/", 
                           list.files("ngrams/full_trim/", paste(i, ".csv$", sep = "")), 
                           sep = "")
        
        ## Set file path for merged N-gram frequecy table
        file_path <- paste("ngrams/merged/ngrams_m_", i, ".csv", sep = "")

        ## Initialize merged N-gram frequency table, identical to first chunk
        chunk <- fread(file_list[1])
        fwrite(chunk, file_path)
        rm(chunk)
        
        ## Function to combine chunks into one with total frequency
        for (j in 2:num_chunks) {
                ## Read N-gram frequency tables
                chunk_a <- fread(file_path)
                chunk_b <- fread(file_list[j])
                
                ## Filter frequency tables to only feature & frequency columns
                chunk_a <- chunk_a[, .(ngram, freq_a = freq)]
                chunk_b <- chunk_b[, .(ngram, freq_b = freq)]
                
                ## Merge frequency tables together
                chunk_m <- chunk_a %>% merge(chunk_b, all = TRUE)
                
                ## Replace NA values with 0s
                chunk_m[is.na(chunk_m)] <- 0
                
                ## Total frequency values
                chunk_m[, freq := freq_a + freq_b]
                
                ## Filter frequency table to only ngram & total frequency columns
                chunk_m <- chunk_m[, .(ngram, freq)]
                
                ## Write frequency table to csv
                fwrite(chunk_m, file_path)
                
                ## Clean up
                rm(chunk_a, chunk_b, chunk_m)
        }
        ## Clean up
        rm(file_list, file_path)
}

## Clean up
rm(i, j, num_chunks)