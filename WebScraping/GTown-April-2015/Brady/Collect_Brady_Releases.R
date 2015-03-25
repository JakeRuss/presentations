###########################
# File: Collect_Brady_Releases.R
# Description: 
#   (1) Loop through Rep. Kevin Brady's website and compile a list of all the 
#       press release urls.
#   (2) Run a second loop through the release urls and download an html copy of 
#       each individual press release. Save these html files to folder. 
# Date: 03/25/2015
# Author: Jake Russ
# Notes:
# To do:
############################

# Load packages
library("httr")
library("rvest")
library("stringr")
library("lubridate")
library("magrittr")

# Working directory 
dir <- paste0(getwd(), "/WebScraping/GTown-April-2015")

# Set user agent
uagent <- "Mozilla/5.0"

# Base web address
base_url <- "http://kevinbrady.house.gov/news"

# Web address for the release all page 
releases_url <- paste0(base_url, "/documentquery.aspx?")

# Initialize an empty data frame to collect all of the press release ids and urls.
links_all <- data.frame(stringsAsFactors = FALSE)

# In this example Kevin Brady's press release website displays his press 
# release links by month and year.

# First stage: Loop through the year and month combinations to collect all of 
# the press release links into a data frame with their ids.

years  <- seq(from = 2009, to = 2014, by = 1)
months <- seq(from = 1, to = 12, by = 1)
#months <- 1:12

# Loop through years and months
for (y in years) {
  
  for (m in months) {
    
    # Make POST request, res is short for response
    res <- POST(releases_url, user_agent(uagent),
                query = list(Year  = y,
                             Month = m))
    
    # The response from the webiste is a list of all the webiste info
    # we specifically want the html document.
    doc <- html(res)
    
    # All of rvest's html_x functions will take CSS selectors or xpath selectors
    # I tend to work with xpath selectors because they tend to be robust.
    # Note: there is an html_node and nodes
    links <- doc %>% 
      html_nodes(xpath = "//ul[@class='UnorderedNewsList']/li/a[1]") %>% 
      html_attr("href")
    
    # Minor error checking for empty pages (e.g. Oct. 2014)
    if (length(links) == 0) {
      links <- NA
    }
    
    # Append the individual press release id to the base url 
    links <- paste0(base_url, "/", links)
    
    # Use a regular expression to extract the document id
    ids <- links %>% 
      str_extract_all(pattern = "[0-9]+") %>% 
      unlist()
    
    # Again, minor error checking for empty pages (e.g. Oct. 2014)
    if (length(ids) == 0) {
      ids <- NA
    }
    
    # Collect ids and urls into temporary data frame.
    tmp <- data.frame(year       = y, 
                      month      = m, 
                      release.id = ids, 
                      url        = links, stringsAsFactors = FALSE)
    
    # Store results in the links_all data frame
    links_all <- rbind(links_all, tmp)
    
    # Be polite to server; between url calls, have the scraper rest for 
    # a few seconds. This makes the scraper slower, but you don't want to 
    # overload Brady's web server.
    Sys.sleep(time = 2)
    
  } # Close "months" for loop
  
} # Close "years" for loop

# How many releases? 
nrow(links_all)     # 657

# Remove NA values
links_all <- links_all %>% subset(!is.na(release.id)) # 656

# Store a copy of the html links
write.csv(links_all, paste0(dir, "/Brady/Brady_Release_links.csv"), 
          row.names = FALSE)

# Second stage - Now that we have all of the press release urls stored in
# links_all, we can loop through that list and download an html copy of every
# press release and save it to a folder.

# Loop through all of the press release links.

for (i in 1:10) {
  
  # Individual press release url
  release_url <- links_all$url[i]
  release_id  <- links_all$release.id[i]
  
  # File path to save a copy of the webpage
  file_path <- paste0(dir, "/Brady/html/Brady_Release_",  release_id, ".html")
  
  # Since we have the direct url for each release, we can do a GET
  # request instead of a POST request. This time we'll also save a copy
  # of the website for each press release. 
  res <- GET(url = release_url, user_agent(uagent),
               write_disk(path = file_path, overwrite = TRUE))
  
  # Again, be polite to server
  Sys.sleep(time = 3)
  
} # Close links_all for loop
