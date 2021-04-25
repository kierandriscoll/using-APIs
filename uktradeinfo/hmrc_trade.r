#' Query the HMRC Overseas Trade Statistics API 
#' @param qfilter
#' A query string containing parameters and values to filter the data by.
#' This string should have double quotes, as character values within the query must be use single quotes   
#' @param qgroupby
#' A query string containing a commas separated list of parameters to group data by.
#' @param class
#' The classification system you are want to use. Either 'HS' or 'SITC'.
#' @return
#' Returns a tidy dataframe with total trade value and weight
get_hmrc_ots <- function(qfilter, qgroupby, class='HS') {

  # OTS Options
  endpoint <- "https://api.uktradeinfo.com/ots"
  qsuppression <- 'and SuppressionIndex eq 0'  # Avoids double counting of suppressed values
  qestimates <- case_when(class == 'HS' ~ " and CommoditySitcId ge -1",
                          class == 'SITC' ~ " and CommodityId ge 0")
  #
  # If filtered by 'EU' region or no country is filtered (ie. whole world) then EU estimates (CountryId 959) will be included. 
  # If Using HS codes then any CommoditySitcId less than -1 should be excluded [add to filter CommoditySitcId ge -1 ]
  # If Using SITC codes then any CommodityId less than -1 should be excluded [add to filter CommodityId ge 0 ]
  # HS2 codes for estimates are negative numbers which arent in the Commodity lookup, so they may get grouped as NA
  #
  
  # Build Query - Automatically include sum of Value and Netmass
  custom_query <- glue::glue('$apply=filter({qfilter} {qsuppression} {qestimates})/groupby(({qgroupby}), aggregate(Value with sum as value, Netmass with sum as weight_kg))&$count=true')
  
  apidata <- hmrc_api_requester(endpoint, custom_query) %>%
    clean_hmrc_api_data()
  
  return(apidata)  
}


#' Query the HMRC Regional Trade Statsistics API 
#' @param qfilter
#' A query string containing parameters and values to filter the data by.  
#' @param qgroupby
#' A query string containing a commas sepearted list of parameters to group data by.
#' @return
#' Returns a tidy dataframe with total trade value and weight
get_hmrc_rts <- function(qfilter, qgroupby) {
  
  # RTS Options
  endpoint <- "https://api.uktradeinfo.com/rts"
  
  # Build Query - Automatically include sum of Value and Netmass
  custom_query <- glue::glue('$apply=filter({qfilter})/groupby(({qgroupby}), aggregate(Value with sum as value, Netmass with sum as weight_kg))&$count=true')
  
  apidata <- hmrc_api_requester(endpoint, custom_query) %>%
    clean_hmrc_api_data()
  return(apidata)  
}


#' Query handler for HMRC API's 
#' @param endpoint
#' One of the HMRC API endpoints e.g. https://api.uktradeinfo.com/ots
#' @param custom_query
#' A query string recognised by HMRC API's (using OData standard)
#' @return
#' Returns a tidy dataframe
hmrc_api_requester <- function(endpoint, custom_query) {

  # Add count to query if not already included 
  if(grepl('count=true', custom_query) == FALSE) {
    custom_query <- paste0(custom_query, '&$count=true')
  }
  
  
  i <- 1
  pagination <- NULL  # HMRC API will only return upto 30,000 records per page
  apidata <- list()
  while (i > 0) {
    req <- httr::GET(endpoint,
                     query = gsub(" ", "%20", paste0(custom_query, pagination)))
    
    
    # Extract content (in json format)
    json_content <- httr::content(req, as = "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON(flatten = TRUE)
    
    # Report Row count
    if (i == 1) {
      message(req$url)
      message(paste("This query will produce", json_content$`@odata.count`, "rows."))
    }
    
    # Add page data to the list
    apidata[[i]] <- json_content$value
    
    # Check for more pages
    if (nrow(json_content$value) == 30000) {
      pagination <- paste0("&$skip=", i * 30000)
      i <- i + 1
    } else {
      i <- 0  # No more pages
    }
    
    # Prevent downlaoding too many rows
    if (json_content$`@odata.count` > 500000) {
      i <- 0  # No more pages
      message("ERROR: Process stopped as this query results in more than 500,000 rows.\nRewrite your query.")
    }
  }

  # Convert list to dataframe and clean column names   
  apidata <- bind_rows(apidata) %>%
    select(-contains("@odata.id")) %>%
    janitor::clean_names()
  
  message(paste0("Total trade (imports + exports) = £", format(sum(apidata$value), big.mark = ',')))
  
  return(apidata)
}


#' Tidies up and recodes HMRC API data  
#' @param df
#' A dataframe downloaded using get_hmrc_ots() or get_hmrc_rts()
#' @return
#' Returns a dataframe
clean_hmrc_api_data <- function(df) {
  
  df <- df %>%
    mutate(flow_type_id = case_when(flow_type_id %in% c(1,3) ~ "Imports",
                                    flow_type_id %in% c(2,4) ~ "Exports",
                                    TRUE ~ ""))

  return(df)  
}



#' Download a HMRC API lookup table 
#' @param table
#' One of the HMRC API lookup table names: 'country', 'region', 'commodity', 'sitc', 'port'
#' @return
#' Returns a tidy dataframe
hmrc_api_lookups <- function(table) {
  
  message(paste0('When using variables from this lookup in an OTS or RTS query you need to prefix them with: ', table, '/'))
  
  req <- httr::GET(paste0("https://api.uktradeinfo.com/", table))
    
  # Extract content (in json format)
  json_content <- httr::content(req, as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(flatten = TRUE)
    
  # Convert json to dataframe and add to list
  apidata <- json_content$value
    
  return(apidata)
}
