###########################
# File: Parse_Brady_Releases.R
# Description: 
#   (1) Create a list object that contains the file names of all the html copies
#       saved during the scraper script.
#   (2) Loop through the html files and extract the press release text for 
#       a potential text analysis. 
#   (3) Save content to a text file.
# Date: 03/25/2015
# Author: Jake Russ
# Notes:
# To do:
############################

# Load packages
library("XML")
library("rvest")
library("stringr")
library("dplyr")
library("magrittr")

# Working directory
dir <- paste0(getwd(), "/WebScraping/GTown-April-2015")

# Create a list of the files in the html subdirectory
html_list <- list.files(path    = paste0(dir, "/Brady/html/"), 
                        pattern = "Brady_")

for (i in html_list){
  
  i <- html_list[7]
  # Remove ".html" from the file name
  filename <- str_replace(string = i, pattern = ".html", replacement = "")

  # Read html document into R
  doc <- html(paste0(dir,"/Brady/html/", i), encoding = "UTF-8")
  
  # Extract the text of the press release using a CSS selector
  xp <- "//div[@class='bodysubheader'][2]"
  release_text <- doc %>%
    html_nodes(xpath = xp) %>% 
    html_text()
  
  # Error catch
  if(length(release_text) == 0) {
    
    xp <- "//div[@class='middlecopy']"
    release_text <- doc %>%
      html_nodes(xpath = xp) %>% 
      html_text()  
    
  }
  
  # Remove garbage characters
  release_text <- release_text %>% 
    str_replace_all(pattern     = "(\n|\r|\t)", 
                    replacement = "")
  
  # Save a copy of the text to a file
  path <- paste0(dir, "/Brady/text/", filename, ".txt")
  cat(release_text, file = path)
  
} # Close html for loop
