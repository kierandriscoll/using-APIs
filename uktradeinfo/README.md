# HMRC Oversease Trade Statistics API
Documentation: https://www.uktradeinfo.com/api-documentation/

The OTS API contains the following fields:
+ MonthId : in format YYYYMM (eg. 202010)
+ FlowTypeId : 1="EU Imports"; 2="EU Exports"; 3="Non-EU Imports"; 4="Non-EU Exports"
+ CommodityId
+ CommoditySitcId
+ CountryId
+ PortId
+ Value
+ Netmass  

In addition you can use linked fields from other tables using the tablename/fieldname format, eg:
+ Date/Year 
+ Country/CountryCodeAlpha
+ Commodity/Hs2Code
+ Commodity/Cn8Code
+ Commodity/Cn8LongDescription
+ Port/PortCodeAlpha

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
The HMRC trade API works with OData which use System Query Options to define what is being requested and allows you to group data and perform calculations.

If you just need to filter an OData API then *$filter=* must be included before you specify the parameters.
You can use differnt operators in the query, however these must be text versions *eq lt gt ne and or*. For example:  
`https://api.uktradeinfo.com/ots?$filter=MonthId gt 202000 and MonthId lt 202099 and CountryId ne 959 and SuppressionIndex eq 0`

If you just want to carry a sequence of transformations (eg. filter() then groupby()) you need out need to use the $apply options and separate each tranformations with a forward slash:  
`https://api.uktradeinfo.com/ots?$apply=filter(MonthId gt 202000 and CountryId eq 959)/groupby((CommodityId, FlowTypeId), aggregate(Value with sum as SumValue))`

To use this in R you will need to write the query manually and construct it (Nb. all whitespace in the query must be replaced by %20):


# Overcoming the rate limit
This API will only return upto 30,000 observations per request.
```r
  i <- 1
  pagination <- NULL  # HMRC API will only return upto 30,000 records per page
  apidata <- list()
  while (i > 0) {
    req <- httr::GET('https://api.uktradeinfo.com/ots',
                     query = gsub(" ", "%20", paste0('$filter=Date/Year eq 2020 and CountryId ne 959', pagination)))
    
    # Extract content (in json format)
    json_content <- httr::content(req, as = "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON(flatten = TRUE)
     
    # Add page data to the list
    apidata[[i]] <- json_content$value
    
    # Check for more pages
    if (nrow(json_content$value) == 30000) {
      pagination <- paste0("&$skip=", i * 30000)
      i <- i + 1
    } else {
      i <- 0  # No more pages
    }
  }
  
  # Convert list to dataframe
  apidata <- bind_rows(apidata) %>%
    select(-contains("@odata.id")) 
 ```

