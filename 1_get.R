library(dplyr)
library(readr)

## Read, combine, & shuffle data
file_list <- paste("data/rawdata/en_US/", list.files("data/rawdata/en_US/"), sep = "")
data <- list()
data <- lapply(file_list, read_lines)
data <- data %>% unlist() %>% sample()

## Take random sample of data, to decrease processing time
## set.seed(42)
## write_lines(sample(data, size = (0.3 * length(data))), "data/sample.txt")

## Function to split data into more manageable chunks
chunk_data <- function(data, num) {
        num_chunks <- num
        l <- floor(length(data) / num_chunks)
        for (i in 1:num_chunks) {
                write_lines(data_chunk <- data[(((i - 1) * l) + 1):(i * l)], 
                            paste("data/chunk_", i, ".txt", sep = ""))
        }
}
## Chunk data
chunk_data(data, 4)

## Clean up
rm(data, file_list, chunk_data)