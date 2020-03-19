library(data.table)

## Grab list of merged N-gram frequency tables
file_list <- paste("ngrams/merged/", list.files("ngrams/merged/", ".csv$"), sep = "")

## Trim tables to N-grams with frequency > 3
for (i in 1:length(file_list)) {
        ngrams <- fread(file_list[i])
        ngrams <- ngrams[freq > 3]
        file_path <- sub(file_list[i], pattern = "merged", replacement = "merged_trim")
        fwrite(ngrams, file_path)
        rm(ngrams, file_path)
}
