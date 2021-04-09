# HMRC Oversease Trade Statistics API
Documentation: https://www.uktradeinfo.com/api-documentation/

## Basic filter
For simple filtering
```r
endpoint <- 'https://api.uktradeinfo.com/OTS'

# API request  
response <- httr::GET(endpoint,
                      query = c(list(MonthId = '202012',
                                     FlowTypeID = NULL, 
                                     SuppressionIndex = 0,
                                     CommodityId = NULL,
                                     CommoditySitcId = NULL
                                     CountryId = 2,
                                     PortId = NULL)))
 
# Parse the results 
cont <- response %>% httr::content(as = "text")
df <-  jsonlite::fromJSON(cont) %>%
  data.frame()
```

## Complex queries
This API can accept more complex queries such as:
`https://api.uktradeinfo.com/ots?$apply=filter(MonthId gt 202000 and MonthId lt 202099 and CountryId ne 959 and SuppressionIndex eq 0)/groupby((Commodity/Hs2Code, FlowTypeId), aggregate(Value with sum as SumValue))`



# Overcoming the rate limit
This API will only return upto 30,000 observations per request.
```r
  i <- 1
   apidata <- list()
   while(i > 0) {
      req <- httr::GET(full_url)
      
      # Extarct content (in json format)   
      json_content <- httr::content(req, as = "text", encoding = "UTF-8") 
      
      # Convert json to dataframe and add to list
      apidata[[i]] <- jsonlite::fromJSON(json_content, flatten = TRUE) %>% data.frame()
      
      if(is.null(apidata[[i]]$X.odata.nextLink[1]) == FALSE) {
         full_url <- apidata[[i]]$X.odata.nextLink[1]
         i <- i + 1
      } else {
         i <- 0
      }
   }
```
