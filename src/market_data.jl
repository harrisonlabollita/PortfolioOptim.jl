abstract type StockData end

struct Stock <: StockData
	ticker::String
	volume::Vector
	high::Vector
	open::Vector
	low::Vector
	close::Vector
	adjclose::Vector
	start_date::String
	stop_date::String
end

function Stock(ticker::String, from::String, to::String)::StockData
	from = string(Integer(datetime2unix(DateTime(from * "T12:00:00"))))
	to   = string(Integer(datetime2unix(DateTime(to * "T12:00:00"))))

	url = "https://query1.finance.yahoo.com/v7/finance/chart/$ticker?&interval=1d&period1=$from&period2=$to" 

	response = HTTP.get(url, cookies = true)
	body = JSON.parse(String(response.body))["chart"]["result"][1]
	info = body["indicators"]["quote"][1]

	return Stock(ticker, info["volume"], info["high"], 
				 info["open"], info["low"], info["close"], 
				 body["indicators"]["adjclose"][1]["adjclose"],
				 from, to
				)
end

