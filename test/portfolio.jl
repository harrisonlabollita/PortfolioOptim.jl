using Test
using PortfolioOptim
using DataFrames

@testset "Portfolio" begin
	tickers = ["TSLA", "GOOG", "F"]
	portfolio = build_portfolio(tickers, "2022-01-01", "2022-02-01")
	annualized_port = AnnualizedPortfolio(portfolio)

	ref_ann_port = Dict("means" => Vector{Float64}([22.26289463043213,136.04272422790527,1010.1684967041016]),
						"cov"   => Matrix{Float64}([[1.0 0.746172 0.740682]; [0.746172 1.0 0.88404]; [ 0.740682 0.88404 1.0]])
						)
	@test sum(abs.(ref_ann_port["means"] .- annualized_port.mean_returns)) < 1e-6
	@test all(abs.(annualized_port.cov_matrix .- ref_ann_port["cov"]) .< 1e-5) == true
end
