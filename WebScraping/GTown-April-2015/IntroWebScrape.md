Introduction to Webscraping with R and rvest
========================================================
author: Jake Russ
date: April 1, 2015
font-family: 'Times'
css: slide_template.css

Georgetown Political Science

What is this strange symbol and why is it useful?
========================================================

## %>%

The package `magrittr` adds a pipe operator to R.

- `x %>% f` **is equivalent to** `f(x)`
- `x %>% f(y)`  **is equivalent to**  `f(x, y)`
- `x %>% f %>% g %>% h`  **is equivalent to**  `h(g(f(x)))`

More pipe fun
========================================================

Can also use "." as an argument placeholder

- `x %>% f(y, .)` is equivalent to `f(y, x)`
- `x %>% f(y, z = .)` is equivalent to `f(y, z = x)`

See more on [GitHub](https://github.com/smbache/magrittr)

Pipes ease the readability of code 
========================================================


```r
library("magrittr")

numbers <- 1:100

mean(sample(x = numbers, size = 5, replace = FALSE), na.rm = TRUE)
```

```
[1] 46.8
```

```r
numbers %>% sample(size = 5, replace = FALSE) %>% mean(na.rm = TRUE)
```

```
[1] 36.6
```

Plan for today: two scraping demos with code
========================================================

1. Scrape headlines from the New York Times
2. Scrape all of Kevin Brady's press releases

We'll use `rvest` from Hadley Wickham [Github link](https://github.com/hadley/rvest)

- Inspired by Python's `BeautifulSoup`

All of the demo code is [posted on Github](https://github.com/JakeRuss/presentations/tree/master/WebScraping)

Best advice: get this book!
========================================================

[Automated Data Collection with R](http://www.r-datacollection.com/)

Published Dec. 2014

Covers basics of HTTP, HTML, XML, JSON, JavaScript and SQL

Does not cover `rvest` and in that sense it is "dated." It is otherwise an 
outstanding reference book. 
