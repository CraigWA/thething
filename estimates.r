library(rvest)
library(data.table)

#this starts a session and logs in
session = html_session("https://www.zacks.com/logout.php")
form = html_form(session)[[4]] #4th form is loginform
filled_form = set_values(form, username="workercraig@gmail.com", password="123456Ab!!")
submit_form(session, filled_form)

table = html_table(xml_child(quarterlyEst, 2))

data.eps = data.table(ticker=character(), estimates=list())

#this uses the session and loads and scrapes data off each page for each ticker in data.tickers and returns a data.table
for(x in 1:data.tickersLength) {
  data.tickers[[2]][x]
  url = paste0("https://www.zacks.com/stock/quote/", data.tickers[[2]][x] ,"/detailed-estimates?adid=zp_quote_detailedest_est")
  page = jump_to(session, url)
  quarterlyEst = page %>% html_node("#quote_quarterly_estimate")
  if(length(quarterlyEst) == 0) next #if there are no quarterly estimates go next iteration
  table = html_table(xml_child(quarterlyEst, 2))
  tableList = asplit(table, 1)
  data.tempEps = data.table(
    ticker = data.tickers[[2]][x],
    estimates = list(tableList)
  )
  data.eps = rbind(data.eps, data.tempEps)
}

return(data.eps)