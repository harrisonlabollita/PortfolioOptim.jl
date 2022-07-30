using Test
using PortfolioOptim
using DataFrames

@testset "Portfolio" begin
	ref = Dict{String,Float64}( "exp_returns" => 0.8286971840585787,
							    "volatility" => 15.29619599921221,
								"sharpe"     => 0.05352292714481061
								)

	tickers = ["TSLA", "GOOG", "F"]
	portfolio = build_portfolio(tickers, "2020-01-01", "2022-01-01")
	weights = ones(length(tickers)) ./ length(tickers)

	annualized_port = AnnualizedPortfolio(portfolio, weights)
	@test (annualized_port.expected_returns - ref["exp_returns"]) < 1e-5
	@test (annualized_port.volatility - ref["volatility"]) < 1e-5
	@test (annualized_port.sharpe - ref["sharpe"]) < 1e-5
end
