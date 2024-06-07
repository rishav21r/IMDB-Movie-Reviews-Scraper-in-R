# IMDB Movie Reviews Scraper with R
This repository contains an R script to scrape movie reviews from IMDB. The script is designed to load any number of pages of reviews as specified by the user for any movie they are interested in. The example provided scrapes reviews for "The Lion King (1994)".

This repository contains an R script to scrape movie reviews from IMDB. The script is designed to load any number of pages of reviews as specified by the user for any movie they are interested in. The example provided scrapes reviews for "The Lion King (1994)".

On the IMDB website, reviews are not loaded all at once; instead, only 25 reviews are present on the first page. To access more reviews, a user must click the "load more" button to fetch the next set of 25 reviews. This process is repeated for each subsequent set of reviews, making manual scraping tedious and time-consuming.

This script automates the process of loading multiple pages to collect a comprehensive set of review data. By programmatically handling the "load more" button, it ensures that all reviews are captured without manual intervention. The script effectively deals with the dynamic content loading implemented via JavaScript on the IMDB site, a task that can be challenging to manage manually.

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

### Scraping Reviews
An empty data frame is initialized to store all reviews. A loop iterates through the specified number of pages, scraping reviews and updating the URL for the next page.
```r
all_reviews <- data.frame() 
for (i in 1:num_pages) {
  # Scrape reviews from the current page
  additional_reviews <- scrape_and_handle_missing(initial_url)
  all_reviews <- bind_rows(all_reviews, additional_reviews)
  
  # Find the link for the next page
  next_page_link <- read_html(initial_url) %>% html_node(".load-more-data") %>% html_attr("data-key")
  
  # Check if a "load more" button is present and update the URL if it is
  if (!is.na(next_page_link)) {
    initial_url <- paste0("https://www.imdb.com/title/tt0110357/reviews/_ajax?paginationKey=", next_page_link)
  } else {
    break  # Stop if there's no more "load more" button
  }
}

```

### Cleaning and Saving the Data
The scraped data is cleaned and saved to a CSV file in the data/ directory.

```r
# Clean data
all_reviews <- apply(all_reviews, 2, trimws)

# Save to CSV
write.csv(all_reviews, file = "data/imdbreviews_thelionking1994.csv", row.names = FALSE)

# View result (optional)
View(all_reviews)

```

### Running the Script
To run the script, open `scrape_reviews.R` in RStudio or any R environment and execute the code. The reviews will be saved in the `data/` directory as imdbreviews_thelionking1994.csv.
