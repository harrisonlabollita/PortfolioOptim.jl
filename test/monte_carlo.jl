using Test
using PortfolioOptim
using Random

Random.seed!(1234);

@testset "MonteCarlo" begin

	tickers = ["TSLA", "GOOG", "F", "FB", "AMZN", "DIS"]
	portfolio = build_portfolio(tickers, "2020-01-01", "2022-01-01")

	@testset "MonteCarloOptimizer" begin
		results = MonteCarloOptimizer(portfolio)
		sharpe  = AnnualizedPortfolioQuantities(results.optim_sharpe_weights, results.portfolio)

		@test (sharpe.sharpe - 1.9680998746128655) < 1e1
		@test (sharpe.volatility  - 0.4114322428826498) < 1e1
		@test (sharpe.expected_returns - 0.8597397456290331) < 1e1
		vol     = AnnualizedPortfolioQuantities(results.optim_vol_weights, results.portfolio)
		@test (vol.sharpe - 1.2000394306062054) < 1e1
	    @test (vol.volatility - 0.2774108063023654 ) < 1e1
	    @test (vol.expected_returns - 0.3829039060390989) < 1e1
	end
end
