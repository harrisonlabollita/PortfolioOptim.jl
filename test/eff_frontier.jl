using Test
using PortfolioOptim

approx_close(vec1, vec2) = sum(abs.(vec1 .- vec2))
	
@testset "EfficientFrontier" begin

	tickers = ["TSLA", "GOOG", "F", "FB", "AMZN", "DIS"]
	portfolio = build_portfolio(tickers, "2020-01-01", "2022-01-01")

	@testset "EfficientOptimizer" begin
		optim_func = [neg_sharpe_ratio, portfolio_volatility, portfolio_returns]

		ref_weights = [[3.66935e-17, 0.0, 1.13842e-17, 0.277824, 0.574092, 0.148084],
					   [0.460063, 0.172875, 2.27682e-18, 0.238672, 0.0, 0.12839],
					   [9.99201e-16, 1.0, 1.249e-15, 0.0, 0.0, 0.0]]

		for (weight, func) in zip(ref_weights, optim_func)
			@test approx_close(EfficientOptimizer(portfolio, func)["x"],  weight) < 1e-5
		end
	end

	@testset "EfficientReturns" begin
		ref_targets = [0.1, 0.2, 0.3]
		ref_weights = [[0.0135429, 0.986457, 0.0, 0.0, 7.37257e-17, 0.0],
					   [0.429235, 0.562975, 0.00778948, 1.9082e-17, 0.0, 1.19262e-17],
					   [0.482428, 0.272462, 2.81893e-17, 0.162415, 0.0, 0.0826946]]

		for (ref_target,ref_weight) in zip(ref_targets, ref_weights)
			@test approx_close(EfficientReturns(portfolio, ref_target)["x"], ref_weight) < 1e-5
		end
	end

	@testset "Frontier" begin
		targets = collect(0.1:0.1:0.5)
		ref_results = Dict{String, Vector{Float64}}("sharpe" => [0.12993201607806137, 0.507454116717179, 0.9164963052063122, 1.2736701582469918, 1.558154890326597],
													"volatility"    => [0.38481662581728476,  0.295593227158829,  0.27277796818551014, 0.27479642020122863, 0.28880312398508523],
													)
		eff_results = EfficientFrontier(portfolio, targets)

		@test approx_close(eff_results.sharpe_ratio, ref_results["sharpe"]) < 1e-5
		@test approx_close(eff_results.volatility, ref_results["volatility"]) < 1e-5
	end

end
