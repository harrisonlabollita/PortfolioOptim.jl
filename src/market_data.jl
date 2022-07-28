function ticker_data(ticker::String, from::String, to::String)
	from = string(Integer(datetime2unix(DateTime(from * "T12:00:00"))))
	to   = string(Integer(datetime2unix(DateTime(to * "T12:00:00"))))

	url = "https://query1.finance.yahoo.com/v7/finance/chart/$ticker?&interval=1d&period1=$from&period2=$to" 

	response = HTTP.get(url, cookies = true)
	body = JSON.parse(String(response.body))["chart"]["result"][1]
	values = body["indicators"]["quote"][1]

	x = Dict( "Ticker" => ticker, 
			  "Adjusted" => body["indicators"]["adjclose"][1]["adjclose"])
	return x
end

function build_portfolio(tickers::Array{String}, from::String, to::String)
	get_ticker_data(x) = ticker_data(x, from, to)
	data = get_ticker_data.(tickers)
	df = DataFrame(Dict(item["Ticker"] => item["Adjusted"] for item in data))
	return df
end
