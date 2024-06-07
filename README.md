# IMDB Movie Reviews Scraper with R
This repository contains an R script to scrape movie reviews from IMDB. The script is designed to load any number of pages of reviews as specified by the user for any movie they are interested in. The example provided scrapes reviews for "The Lion King (1994)".

## Prerequisites
Before running the script, please ensure you have the necessary R packages installed. The required packages are rvest and dplyr. *(Complete code block can be found here: [scrape_imdbreview.R](scrape_imdbreview.R))*
```r
# Install required packages (if not already installed)
install.packages('rvest')
install.packages('dplyr')
```

## Script Overview
### Loading Necessary Libraries
The script starts by loading the required libraries.

```r
library(rvest)
library(dplyr)
```

### Defining the Scraping Function
A function scrape_and_handle_missing is defined to scrape reviews from a given URL and handle any missing values.

```r
scrape_and_handle_missing <- function(url) {
  webpage <- read_html(url)
  
  review_title <- webpage %>% html_nodes(".title") %>% html_text()
  review_date <- webpage %>% html_nodes(".review-date") %>% html_text()
  rating_out_of_10 <- webpage %>% html_nodes(".rating-other-user-rating") %>% html_text()
  review_content <- webpage %>% html_nodes(".text") %>% html_text()
  
  # Handle missing values
  max_length <- max(length(review_title), length(review_date), length(rating_out_of_10), length(review_content))
  review_title <- c(review_title, rep("NA", max_length - length(review_title)))
  review_date <- c(review_date, rep("NA", max_length - length(review_date)))
  rating_out_of_10 <- c(rating_out_of_10, rep("NA", max_length - length(rating_out_of_10)))
  review_content <- c(review_content, rep("NA", max_length - length(review_content)))
  
  data.frame(Title = review_title, Date = review_date, Rating = rating_out_of_10, Content = review_content)
}

```

### Initializing the URL and Setting the Number of Pages
Define the initial URL of the movie reviews page and set the number of pages to scrape.

```r
initial_url <- "https://www.imdb.com/title/tt0110357/reviews/?ref_=tt_ov_rt" # Replace with the desired IMDB movie URL
num_pages <- 10  # Set the number of pages to scrape

```
