# GDELT API
Documentation: https://blog.gdeltproject.org/gdelt-doc-2-0-api-debuts/


## Basics

```r
endpoint <- 'https://api.gdeltproject.org/api/v2/doc/doc'  
  
# API request  
response <- httr::GET(endpoint,
                      query = c(list(query = 'Olympics',
                                     timespan = '12m',
                                     startdatetime = NULL,
                                     enddatetime = NULL,
                                     mode = 'TimelineVol',
                                     maxrecords = 250, # GDELT Maximum 
                                     format = 'json')))
                                     
# Parse the results
cont <- httr::content(response, "text")
json <- jsonlite::fromJSON(cont)

# Convert list into dataframe
names(json$timeline$data) <- json$timeline$series  
df <- bind_rows(json$timeline$data, .id = "series")
```


## Function
```r
#' Extarcts data from GDELT 
#' @param search_query
#' A query string containing search words and operators (AND OR). Use " " to search for whole phrases.
#' An example: 'investment AND "Northern Powerhouse" sourcecountry:france'
#' There are special operators available such as sourcecountry, sourcelang, domain, theme. See GDELT documentation for more.  
#' @param time_span
#' Specify the number of months, weeks, days of results to return (from today) using the suffix "m", "w", "d".
#' @param output_mode
#' Specify the type of results. "TimelineVol" (default) returns the volume of news as % of all news each day.
#' Other options are: "TimelineVolRaw" gives the raw number of articles.  "TimelineTone" gives the overall sentiment (+/-ve).
#' "TimelineLang" shows the relative volume by language, "TimelineSourceCountry" shows the relative volume by source country.
#' "ArtList" returns a full list of articles.
#' @param source_country
#' The name of a country to limit the query to. Example "United States".
#' By default this is NULL, so all countries are included.  
#' @return
#' Returns a dataframe containing all results
extract_gdelt_data <- function(search_query = NULL,
                               time_span = '12m',
                               output_mode = 'TimelineVol',
                               source_country = NULL) {
 
  url <- "https://api.gdeltproject.org/api/v2/doc/doc?"  
  
  # Check if a source is supplied
  src <- ifelse(is.null(source_country), "", paste0("sourcecountry:", gsub("\\s", "", source_country)))
  
  # API request  
  r <- httr::GET(url, query = c(list(query = paste(search_query, src),
                                     timespan = time_span,
                                     mode = output_mode,
                                     maxrecords = 250, # GDELT Maximum 
                                     format = 'json')))
    
  message("Query used: ", r$url)
  httr::stop_for_status(r)
    
  # Parse the results
  con <- httr::content(r, "text")
  json <- jsonlite::fromJSON(con)
  
  if(output_mode %in% c("TimelineVol", "TimelineVolRaw", "TimelineTone", "TimelineLang", "TimelineSourceCountry")) { 
    
    # Add names to all items in data list
    names(json$timeline$data)<- json$timeline$series  
  
    # Convert data list into dataframe
    df <- bind_rows(json$timeline$data, .id = "series") %>%
      mutate(date = as.Date(date, format= "%Y%m%dT%H%M%SZ"))
    
  } else if(output_mode %in% "ArtList") {
    
    message("Only upto 250 articles can be returned at at a time.")
    df <- json$articles %>%
      mutate(date = as.Date(seendate, format= "%Y%m%dT%H%M%SZ"))
    
  } else {
    
    message("Mode not known. Output is in JSON format.")
    df <- json
    
  }
  
  return(df)
  
}
```
