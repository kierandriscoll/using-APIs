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
You just need to specify the endpoint and the parameters you want to filter by.
For example the following request returns HMRC data for exports to Germany in Dec 2020:  
```r
endpoint <- 'https://api.uktradeinfo.com/OTS'

result_json <- httr::GET(endpoint,
                         query = c(list(MonthId = '202012',
                                        FlowTypeID = 1,
                                        CountryId = 4))) %>%
  httr::content(as = "text")
 ```  
  
{jsonlite} can convert the results from JSON format to an R object:  
```r
result_df <-  jsonlite::fromJSON(result_json) %>%
  data.frame()
```

# Issues
Some API's return complex data structures, with nested values. You may need to add the *flatten* option when converting from JSON to resolve this.  
```r
jsonlite::fromJSON(result_json, flatten = TRUE)
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
