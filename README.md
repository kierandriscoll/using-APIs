# Extracting data from APIs
Application Programming Interfaces (API's) are a way of allowing your computer to request/query information from another computer or application. You can think of it as querying a remote database that is hosted on a website. 

# What API's can i use
There is a catalogue of government API's : https://www.api.gov.uk/#uk-government-apis including access to data from:  
- Companies House  
- ONS (Statistics and Open Geography)  
- HMRC & DIT (Trade and tariffs)  
- TfL 

Other organisation also have API's although these may be behind paywalls or require an account:  
Trade : https://comtrade.un.org/data/dev/portal#subscription  
News : https://blog.gdeltproject.org/announcing-the-gdelt-context-2-0-api/  
Social Media : https://developer.twitter.com/en/docs/twitter-api 
                                   
# Main features of an API:
**Base URL** : This is the main address of the API. Some examples are:  
DIT's Tariff API: https://www.trade-tariff.service.gov.uk/api/v2  
HMRC's Trade API: https://api.uktradeinfo.com
                                    
Nb: Some large API's contain multiple 'databases', and each one will have its own endpoint after the base URL. For example:
https://api.uktradeinfo.com/OTS  
https://api.uktradeinfo.com/RTS

**Parameters** : These are options you will use to query the API, such as filtering (eg. Year=2020). Parameters will be different for each API.

**JSON output** : API's will normally return data as JSON which is a structured text format. Eg:
`{[{{"MonthId":200001,"FlowTypeId":1,"CommodityId":-990,"CountryId":959,"PortId":-1,"Value":148391144.0,"NetMass":null}]}`
                                    
**Rate Limiting** : Some API's have restrictions on the number of requests and/or the number of items that can be returned per request.

**Tokens (for access/authentication)** : Some API's require an access token (you may need to setup an account) to use them. Open Data/Government  API's do not normally need tokens.


# R & APIs
To use an API in R you will need to the **{httr}** and **{jsonlite}** packages.

{httr} handles the API request and response with its GET() function.  
You need to specify the endpoint and a query that will filter results.
For example the following request returns the number of news articles that mentioned the Olympics in the last 12 months:  
```r
endpoint <- 'https://api.gdeltproject.org/api/v2/doc/doc'

response <- httr::GET(endpoint,
                      query = c(list(query = 'Olympics',
                                     timespan = '12m',
                                     mode = 'TimelineVol',
                                     format = 'json'))) %>%
  httr::content(as = "text")
 ```  
  
{jsonlite} can convert the results from JSON format to an R object:  
```r
result <-  jsonlite::fromJSON(response)
```

# More complex queries
The example above is the simplest type of query for an API. However it doesnt allow complex conditions such as < > OR NOT.

Some API's use a system called OData which can allows you to do calculation and grouping however it is more complex to write a query

## OData queries
These types of query use *System Query Options* to define what is being requested. These start with a $ (eg. $filter, $apply ...) 
A complex OData query could look like:
`https://api.uktradeinfo.com/ots?$apply=filter(MonthId gt 202000 and MonthId lt 202099 and CountryId ne 959 and SuppressionIndex eq 0)/groupby((Commodity/Hs2Code, FlowTypeId), aggregate(Value with sum as SumValue))`

If you just need to filter an OData API then *$filter=* must be included befor you specify the parameters. Also you must use text versions of operators *eq lt gt ne and* within the query instead of *= < > != &. For example:  
`https://api.uktradeinfo.com/ots?$filter=MonthId gt 202000 and MonthId lt 202099 and CountryId ne 959 and SuppressionIndex eq 0`

If you just want to carry a sequence of transformations (eg. filter then groupby) you need out need to use the $apply options and sepearte each tranformations with a /.
`https://api.uktradeinfo.com/ots?$apply=filter(MonthId gt 202000 and CountryId eq 959)/groupby((CommodityId, FlowTypeId), aggregate(Value with sum as SumValue))`

To use this in R you will need to write the query manually and construct it (Nb also that all balnak spaces must be repalced by %20):
```r
endpoint <- 'https://api.uktradeinfo.com/ots'

response <- httr::GET(endpoint,
                      query = '$filter=MonthId eq 202001') %>%
  httr::content(as = "text")
 ```  

# Handling results
If the API is relatively simpe it should return a dataframe, but API's may return more complex data structures that need more processing.  
```r
# If the results include nested values then you can flatten them:
result <- jsonlite::fromJSON(result, flatten = TRUE)

# If the result is a list object then you can convert to a dataframe:
df <- bind_rows(result$timeline$data, .id = "series") 
```

# API Documentation
Every API will have a different set of endpoints, parameters and some operate slightly differently, so you need to read its documentation to understand how to use it.   
                                    
# Queries in a browser
You can enter API queries directly in your browser and see the JSON ouptut, but you will need to write the full request manaully.
A full query might look something like :  
`https://api.uktradeinfo.com/OTS?MonthId gt 201901 & CountryId eq 959`
- This starts with the base URL and endpoint.
- The query starts with a **?**
- The parameters and conditions can then be specified with each one sepearted by **&**.
Nb. Some API's accept conditional operators such as *= < > !=* but others only accept text versions, *eq lt gt ne*.
