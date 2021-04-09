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
**Base Endpoint** : This is the main address of the API. Some examples are:  
DIT's Tariff API: https://www.trade-tariff.service.gov.uk/api/v2  
HMRC's Trade API: https://api.uktradeinfo.com

Nb: Some large API's contain multiple 'databases', and each one will have its own endpoint after the base endpoint. For example:
https://api.uktradeinfo.com/OTS  
https://api.uktradeinfo.com/RTS

**Parameters** : These are options you will use to query the API, such as filtering (eg. Year=2020). Parameters will be different for each API.

**JSON output** : API's will normally return data as JSON which is a structured text format. Eg:
`{[{{"MonthId":200001,"FlowTypeId":1,"CommodityId":-990,"CountryId":959,"PortId":-1,"Value":148391144.0,"NetMass":null}]}`

**Rate Limiting** : Some API's have restrictions on the number of requests and/or the number of items that can be returned per request.

**Tokens (for access/authentication)** : Some API's require an access token (you may need to setup an account) to use them. Open Data/Government  API's do not normally need tokens.


# R & APIs
To use an API in R you will need to the **{httr}** and **{jsonlite}** packages.

{httr} handles the API request and response.  
You just need to enter your query into the GET() function. Eg:  
`myquery <- 'https://www.trade-tariff.service.gov.uk/api/v2/quotas/search?geographical_area_id=US&years=2020'
result_json <- httr::GET(myquery) %>% 
  httr::content(as = "text")`  
  
{jsonlite} can convert the results from JSON format to an R dataframe:  
`result_df <-  jsonlite::fromJSON(result_json)`


# API Documentation
The type of requests you can make and the response you get is different for each API, so you will need to read its documentation to understand how to use it.  
For example some API's accept conditional operators such as *= < > !=* but others only accept text versions, *eq lt gt ne*.
https://api.trade-tariff.service.gov.uk/reference.html#trade-tariff-public-api-v2  
https://www.uktradeinfo.com/api-documentation/

# How to send a query/request to the API
You can get the entire contents of a API from the endpoint address, eg: https://api.uktradeinfo.com/OTS  
However normally you will need to query this in order to filter or group items. The query format is similar for all API's.

A query starts with **?** and is followed by the conditions you want to use.
These conditions need to be based on the API parameters (i.e field names used in the API) and values, For example:   
https://api.uktradeinfo.com/OTS?MonthId gt 201901  
This endpoint contains a database of monthly trade statistics. The query above filters this so that it only returns data after Jan 2019 (in this API dates are stored in YYYYMM format).  

More conditions can be included by adding an **&**. For example:   
https://api.uktradeinfo.com/OTS?MonthId gt 201901 & CountryId eq 959 





## Issues
Some API's have complex data structures, such as nested data.
