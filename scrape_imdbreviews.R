# Install required packages (if not already installed)
# install.packages('rvest')
# install.packages('dplyr')

# Load necessary libraries
library(rvest)
library(dplyr)

# Function to scrape reviews and handle missing values
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

# Define the initial URL
initial_url <- "https://www.imdb.com/title/tt0110357/reviews/?ref_=tt_ov_rt" # Replace with the desired IMDB movie URL
num_pages <- 10  # Set the number of pages to scrape 

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

# Clean data
all_reviews <- apply(all_reviews, 2, trimws)

# Save to CSV
write.csv(all_reviews, file = "data/imdbreviews_thelionking1994.csv", row.names = FALSE)

# View result (optional)
View(all_reviews)
