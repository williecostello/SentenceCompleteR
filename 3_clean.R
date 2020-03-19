library(data.table)

## Grab list of raw unmerged N-gram frequency tables
file_list <- paste("ngrams/full/", list.files("ngrams/full", ".csv$"), sep = "")

## Trim tables to N-grams with no punctuation or digits
for (i in 1:length(file_list)) {
        ngrams <- fread(file_list[i])
        ngrams <- ngrams[, .(ngram = feature, freq = frequency)]
        ngrams <- ngrams[!(ngram %like% "^-|^_|#|@|[[:digit:]]"), ]
        file_path <- sub(file_list[i], pattern = "full", replacement = "full_trim")
        fwrite(ngrams, file_path)
        rm(ngrams, file_path)
}
