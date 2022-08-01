using Test
using PortfolioOptim

@testset "Portfolio" begin
	ref = Dict{String,Float64}( "exp_returns" => 0.8286972034068468,
							    "volatility" =>  0.39826357026487336,
								"sharpe"     =>  1.9552308108144518
								)

	tickers = ["TSLA", "GOOG", "F"]
	portfolio = build_portfolio(tickers, "2020-01-01", "2022-01-01")

	weights = ones(length(tickers)) ./ length(tickers)

	ann_port_quant  = AnnualizedPortfolioQuantities(weights,
											   portfolio.mean_returns,
											   portfolio.cov_matrix,
											   portfolio.risk_free_rate,
											   portfolio.freq
											   )

	@test (ann_port_quant.expected_returns - ref["exp_returns"]) < 1e-8
	@test (ann_port_quant.volatility - ref["volatility"]) < 1e-8
	@test (ann_port_quant.sharpe - ref["sharpe"]) < 1e-8
end
