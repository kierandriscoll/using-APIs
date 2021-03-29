# APIs
Application Programming Interfaces (API's) are a way of allowing a computer to request/query information from another computer or application. You can think of it as querying a remote database that is hosted on a website. 

In general you will send a request and the other computer/application will send a response. The type of requests you can make and the response you can get is different for each API you use.  

# API Documentation
To be able to use an API you need to read the its documentation. Eg: 
https://api.trade-tariff.service.gov.uk/reference.html#trade-tariff-public-api-v2
https://www.uktradeinfo.com/api-documentation/

# Main features of an API:
**Base Endpoint** : This is the main address of the API. Some example are:
https://www.trade-tariff.service.gov.uk/api/v2
https://api.uktradeinfo.com

Nb: Some large API's contain multiple 'databases', and each one will have its own endpoint after the base endpoint. For example:
https://api.uktradeinfo.com/OTS  
https://api.uktradeinfo.com/RTS

**Rate Limiting** : Some API's have restrictions on the number of requests and/or the number of items that can be returned per request.

**Tokens (for access/authentication)** : Some API's require an access token (you may need to setup an account) to use them. Open Data/Governmnet  API's do not normally need tokens.

# How to send a query/request to the API
You can get the entire contents of a API from the endpoint address, eg: https://api.uktradeinfo.com/OTS  
However normally you will need to query this in order to filter or group items. The query format is similar for all API's.

A query starts with **?** and is followed by the conditions you want to use.
These conditions need to be based on the API parameters (i.e field names used in the API) and values, For example:   
https://api.uktradeinfo.com/OTS?MonthId gt 201901  
This endpoint contains a database of monthly trade statistics. The query above filters this so that it only returns data after Jan 2019 (in this API dates are stored in YYYYMM format).  

More conditions can be included by adding an **&**. For example:   
https://api.uktradeinfo.com/OTS?MonthId gt 201901 & CountryId eq 959 

## Differences
There can be differences between API's in how queries can be written. For example some API's accept conditional operators such as *= < > !=* but others only accept text versions, *eq lt gt ne*.




# What does the API return
API's will normally return data in JSON format. eg:
`{[{{"MonthId":200001,"FlowTypeId":1,"SuppressionIndex":0,"CommodityId":-990,"CommoditySitcId":-1,"CountryId":959,"PortId":-1,"Value":148391144.0,"NetMass":null,"SuppUnit":null}]}`



# Getting data from an API in R
To get results from an API in R you will need to the **{httr}** and **{jsonlite}** packages.

{httr} handles requests and repsosnes to an API.  
You just need to enter your query into the GET() function. Eg:  
`result_json <- httr::GET('https://www.trade-tariff.service.gov.uk/api/v2/quotas/search?geographical_area_id=US&years=2020') %>% 
  httr::content(as = "text")`  
  
{jsonlite} can convert data from JSON format to a dataframe format:  
`result_df <-  fromJSON(result_json)`

## Issues
Some API's have complex data structures, such as nested data.
