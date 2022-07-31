using Test
using PortfolioOptim

#TODO: create better test
@testset "MarketData" begin
	tickers = ["F", "GOOG", "AAPL", "TSLA"]
	for ticker in tickers
		@test Stock(ticker, "2021-01-01", "2022-01-02").ticker == ticker
	end
end
