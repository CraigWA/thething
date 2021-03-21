library(rvest)
library(data.table)
library(RSelenium)
library(stringr)
#initiate selenium
driver <- rsDriver(browser=c("chrome"), chromever="88.0.4324.96")
remote_driver <- driver[["client"]]
#remote_driver$open()
remote_driver$navigate("https://www.barchart.com/stocks/indices/russell/russell2000")
b = read_html(remote_driver$getPageSource()[[1]]) #translate rselenium to html for rvest

#get loop length
c = html_node(b, "div.pagination-info") #find element by class name
cc = html_text(c) #get text of element
tickerLength = str_match(cc, "(?s)of (.*?)\n")[2] #regex out the number of tickers
tickerLength = ceiling(strtoi(tickerLength) / 100) #convert to int and divide by 100 then round to whole number, 100 tickers per page

data.russel2k = data.table()

for(i in 1:tickerLength) {
  url = paste0("https://www.barchart.com/stocks/indices/russell/russell2000?viewName=main&page=", i)
  remote_driver$navigate(url)
  Sys.sleep(7) #wait 7 seconds, this may not be necessary try testing without
  #perhaps the sleep can be replaced by a check if table exists if not sleep otherwise proceed
  b = read_html(remote_driver$getPageSource()[[1]]) #translate rselenium to html for rvest
  bb = html_node(b, "ng-transclude") #find element holding table data by name
  d = html_table(xml_child(bb, 1)) #populate table with data from page
  d = d[-c(length(d)), ] #remove header row
  data.russel2k = rbind(data.russel2k, d)
}
remote_driver$close()
driver$server$stop
