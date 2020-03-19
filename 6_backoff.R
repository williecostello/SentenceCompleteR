library(data.table)

## Grab list of merged & trimmed N-gram frequency tables
file_list <- paste("ngrams/merged_trim/", 
                   list.files("ngrams/merged_trim/", ".csv$"), sep = "")

## Compute score of each N-gram based on Stupid Backoff scoring function
for (i in 5:2) {
        ngrams_n <- fread(file_list[i])
        ngrams_m <- fread(file_list[i-1])
        multi <- 0.4^(5:0)[i]
        ngrams_n[, score := 0]
        for (j in 1:nrow(ngrams_n)) {
                ngram_n <- ngrams_n[j, 1]
                ngram_m <- sub(ngram_n, 
                               pattern = "_[[:alpha:]]*$", replacement = "")
                count <- ngrams_n[j, 2]
                total <- ngrams_m[ngram == ngram_m][1, 2]
                ngrams_n[j, score := multi * (count / total)]
        }
        ngrams_n[, freq := NULL]
        scores <- na.omit(setorder(ngrams_n, -score))
        fwrite(scores, paste("scores/scores_", i, ".csv", sep = ""))
        rm(ngrams_n, ngrams_m, scores, ngram_n, ngram_m)
}