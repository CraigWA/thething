library(httr)
library(data.table)


#data.exchanges = getExchanges()
main()

date1 = as.Date('2021-03-02')
date2 = as.Date('2021-02-02')
portfolio = data.table(ticker = c("GD"))

backtest = function (portfolio, date1, date2) {
  #portfolio should be a data table with ticker and buy price
  #get a count of days between dates
  #calculate profit between two dates
  #date1 is the last day and date2 is the first day in the range
  for(x in 1:nrow(portfolio[1])) {
  indexDate1 = grep(as.character(date1), data.masterTable[[5]][[x]])
  indexDate2 = grep(as.character(date2), data.masterTable[[5]][[x]])
  price1 = data.masterTable[[5]][[x]][indexDate1][[1]]$close
  price2 = data.masterTable[[5]][[x]][indexDate2][[1]]$close
  portfolio[[2]][x] = price1 - price2
  }
  colnames(portfolio) = c("ticker", "return")
}

main = function() {
  
  data.ndaqTickers = getTickers('XNAS')
  data.nyseTickers = getTickers('XNYS')
  data.tickers = rbind(data.ndaqTickers, data.nyseTickers)
  data.tickersLength = nrow(data.tickers)
  
  data.masterTable = data.table(ticker=character(), qBalSheet=list(), qCashFlow=list(), qIncome=list(), histDailyPrice=list(), marketCap=list())
  
  for(x in 1:data.tickersLength) {
    
    ticker = data.tickers[x, 2]
    data.qBalSheet = getqBalSheet(ticker)
    data.qCashFlow = getqCashFlow(ticker)
    data.qIncome = getqIncome(ticker)
    data.histDailyPrice = getHistDailyPrice(ticker)
    data.marketCap = getMarketCap(ticker)
    
    data.tempTable = data.table(
      ticker=ticker, 
      qBalSheet=list(data.qBalSheet), 
      qCashFlow=list(data.qCashFlow), 
      qIncome=list(data.qIncome), 
      histDailyPrice=list(data.histDailyPrice),
      marketCap=list(data.marketCap)
      )

    data.masterTable = rbind(data.masterTable, data.tempTable)
    
    }
  }

getqBalSheet = function(ticker) {
  rawData = content(GET(paste0("https://financialmodelingprep.com/api/v3/balance-sheet-statement/", ticker ,"?period=quarter&limit=9999&apikey=ecdd75abb75a1570eaa4ba2359cb874e")))
  return(rawData)
}

getqCashFlow = function(ticker) {
  rawData = content(GET(paste0("https://financialmodelingprep.com/api/v3/cash-flow-statement/", ticker ,"?period=quarter&limit=9999&apikey=ecdd75abb75a1570eaa4ba2359cb874e")))
  return(rawData)
}

getqIncome = function(ticker) {
  rawData = content(GET(paste0("https://financialmodelingprep.com/api/v3/income-statement/", ticker ,"?period=quarter&limit=9999&apikey=ecdd75abb75a1570eaa4ba2359cb874e")))
  return(rawData)
}

getMarketCap = function(ticker) {
  rawData = content(GET(paste0("https://financialmodelingprep.com/api/v3/historical-market-capitalization/", ticker ,"?limit=9999&apikey=ecdd75abb75a1570eaa4ba2359cb874e")))
  return(rawData)
}

getHistDailyPrice = function(ticker) {
  rawData = content(GET(paste0("https://financialmodelingprep.com/api/v3/historical-price-full/", ticker ,"?apikey=ecdd75abb75a1570eaa4ba2359cb874e")))
  return(rawData$historical)
  }

getExchanges = function() {
  #reinspect this
  rawData = content(GET("http://api.marketstack.com/v1/exchanges?access_key=e828414659dbdfdcf17f3bf8fc08a4ff"))
  dt = rbindlist(rawData$data)
  return(dt)
}

getTickers = function(mic) {
  #reinspect this
  rawData = content(GET(paste0("http://api.marketstack.com/v1/exchanges/", mic ,"/tickers?limit=1000&access_key=e828414659dbdfdcf17f3bf8fc08a4ff")))
  numPages = floor(rawData$pagination$total / 1000)
  dt = rbindlist(rawData$data$tickers)
  for (x in 1:numPages) {
    count = x * 1000
    a = content(GET(paste0("http://api.marketstack.com/v1/exchanges/", mic ,"/tickers?limit=1000&offset=", count ,"&access_key=e828414659dbdfdcf17f3bf8fc08a4ff")))
    b = rbindlist(a$data$tickers)
    dt = rbind(dt, b)
  }
  return(dt)
}

#"http://api.marketstack.com/v1/exchanges/XNAS/tickers?limit=50&offset=990&access_key=e828414659dbdfdcf17f3bf8fc08a4ff"
