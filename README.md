# SentenceCompleteR

A simple word prediction app, using a N-gram prediction model & written in R. Try it out here: [williecostello.shinyapps.io/SentenceCompleteR](https://williecostello.shinyapps.io/SentenceCompleteR/)


## Synopsis

SentenceCompleteR is a simple word prediction app that predicts the next word in a sentence based on the last five words typed in. To use, simply type a sentence into the textbox on the left sidebar of the app. 

The algorithm's top prediction is presented in bold at the top of the app, as completing the sentence typed in, and its top five predictions are displayed in a table below. Scores for each prediction are also listed in this table, so that one can see how strong its five predictions are, relative to one another. Scores range from 0 to 100; the higher the score, the stronger the prediction.

SentenceCompleteR's predictions are based on a corpus of blog posts, news stories, and tweets provided by [SwiftKey](https://www.microsoft.com/en-us/swiftkey) as part of the [Coursera Data Science Specialization](https://www.coursera.org/specializations/jhu-data-science) capstone course. The original dataset contained over 4,000,000 lines of text and took up over 800 Mb of space. With data processing, SentenceCompleteR's predictions are computed using a data table that takes up less than 100 Mb of space.

All scripting for SentenceCompleteR was completed in R, relying primarily on the [`quanteda`](https://quanteda.io/) and [`data.table`](https://rdatatable.gitlab.io/data.table/) packages.


## File directory

The files in this repository can be used to reconstruct the SentenceCompleteR algorithm from the original dataset (or a similar dataset).

- `1_get.R` Reads, combines, & chunks data
- `2_build.R` Builds 2- to 6-gram frequency tables for each data chunk
- `3_clean.R` Cleans up frequency tables for faster processing
- `4_combine.R` Combines frequency tables chunks into single table with total frequency
- `5_trim.R` Trims frequency tables to N-grams with frequency > 3, for faster processing
- `6_backoff.R` Compute score of each N-gram based on Stupid Backoff scoring function
- `7_predict.R` Generate list of top five next word completions of input string
- `ui.R` User interface file for Shiny App
- `server.R` Server file for Shiny App (broadly identical to `7_predict.R`)


## Under the hood

Our prediction algorithm is based on a simple **N-gram model** using the **Stupid Backoff scoring function**.

In essence, an N-gram model works by analyzing a corpus of text into strings of consecutive words. From our original dataset of 4,000,000 blogs, news stories, and tweets, we computed **every 1- to 6-word string** that appeared in this dataset and then calculated the **frequency** of each unique string (i.e., how many times it occurred in the dataset).

To make its predictions, our algorithm uses these frequency counts to determine: **Which words are the most common completions of the last five words typed in?** For example, "times" is a very common completion of the phrase "It was the best of". In our dataset, "times" is found to complete this sentence 87.5% of the time. This number is calculated by taking the frequency count of the phrase "It was the best of times" in the entire dataset, divided by the frequency count of the phrase "It was the best of". This calculation tells us what percentage of the time the phrase "It was the best of" is completed by "times".

Sometimes the best completion is not based on the last five words typed in, but on the last four, three, two, or even one. Our algorithm automatically takes such considerations into account. In addition to determining the most common completion of the last five words typed in, it also determines the most common completions of the last four, three, two, and one words typed in. It then weighs those completions accordingly (multiplying each completion percentage by a factor of 0.4 for each level) and compares the scores of all percentages. The highest scoring completion is the algorithm's top prediction.