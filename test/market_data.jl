using Test
using PortfolioOptim
using DataFrames

@testset "MarketData" begin
	tickers = ["F", "GOOG", "AAPL", "TSLA"]
	portfolio = build_portfolio(tickers, "2022-01-01", "2022-02-01")
	ref_portfolio_describe = Dict("mean" => Vector{Float64}([169.3964744567871, 
															 22.26289463043213, 
															 136.04272422790527, 
															 1010.1684967041016]),
								  "variable" => Vector{Symbol}([:AAPL, :F, :GOOG, :TSLA]))
	description = describe(portfolio)
	@test ref_portfolio_describe["variable"] == description[!, "variable"]
	@test sum(abs.(ref_portfolio_describe["mean"] .- description[!, "mean"])) < 1e-5
end
