using PortfolioOptim
using Test

@testset "PortfolioOptim.jl" begin
	include("market_data.jl")
	include("portfolio.jl")
end
