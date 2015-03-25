###########################
# File: ScrapeNYT.R
# Description: Interactive introduction to scraping the NY Times with rvest
# Date: 03/25/2015
# Author: Jake Russ
# Notes:
# To do:
############################

library("rvest")    # devtools::install_github("hadley/rvest")
library("magrittr") # Adds pipe operator
library("stringr")  # Set of string manipulation tools

# Working directory 
dir <- paste0(getwd(), "/WebScraping/GTown-April-2015")

# Web adress for the site we want to scrape
nyt_url <- "http://www.nytimes.com"

# Use rvest's html function to read in html source document (encoding is optional)
doc <- html(x = nyt_url, encoding = "UTF-8") 

# Two ways to extract stuff out of the html

# (1) CSS tool: http://selectorgadget.com/
css_selector   <- ".story-heading a"

# (2) XPATH tool: Chrome extension "Xpath Helper" by Adam Sadovsky
xpath_selector <- "//*[contains(@class, 'story-heading')]/a"

# Extract the headlines using css
headlines_css <- doc %>% 
  html_nodes(css = css_selector) %>% 
  html_text()

# Extract the headlines using xpath
headlines_xpath <- doc %>% 
  html_nodes(xpath = xpath_selector) %>%
  html_text()

# Notice that there are still some garbage characters in the scraped text
head(headlines_css, 20)
head(headlines_xpath, 20)

# Clean the headlines with regular expressions
# Regex tool: http://www.regexr.com/
clean_headlines <- headlines_xpath %>%
  # (1) Remove line breaks
  str_replace_all(pattern = "\\n" , replacement = " ") %>%
  # (2) Remove blocks of double-spacing
  str_replace_all(pattern = "(  )", replacement = "") %>%  
  # (3) Remove white space from beginning and end
  str_trim()

head(clean_headlines, 20)

# What if we also wanted the links embedded in those headlines?
links_xpath <- doc %>% 
  html_nodes(xpath = xpath_selector) %>%
  html_attr(name = 'href')

head(links_xpath)

# What day did we grab the headlines?
headlines_date <- doc %>%
  html_nodes(css = ".date") %>%
  html_text()

# We could turn these vectors into a data frame
combined <- data.frame(date     = headlines_date, 
                       headline = clean_headlines, 
                       link     = links_xpath, stringsAsFactors = FALSE)

# What if we wanted the story text from one of those? (same general process)

story_url   <- combined$link[1]

story_doc   <- html(story_url)

story_title <- story_doc %>%
  html_nodes(css = "#story-heading") %>%
  html_text()

story_text <- story_doc %>% 
  html_nodes(css = ".story-body-text") %>%
  html_text() %>%
  str_c(collapse = " ")

story_byline <- story_doc %>%
  html_nodes(css = ".byline") %>%
  html_text() %>%
  str_c(collapse = "")

story_date <- story_doc %>%
  html_nodes(css = "#story-meta-footer .dateline") %>%
  html_text()

# Write the story text to file
cat(story_text, file = paste0(dir, "/Ambassador.txt"), append = FALSE) 

# Document metadata of collected story
story_df <- data.frame(date      = story_date,
                       headline  = story_title, 
                       writer    = story_byline,
                       link      = story_url,
                       timestamp = Sys.time(), stringsAsFactors = FALSE)
