using PortfolioOptim
using Test

@testset "PortfolioOptim.jl" begin 
	include("market_data.jl")
	include("portfolio.jl")
	include("eff_frontier.jl")
	include("monte_carlo.jl")
end
