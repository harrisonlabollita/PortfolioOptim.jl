using PortfolioOptim
using Plots

tickers = ["GOOG", "DIS", "FB", "AMZN", "AAPL", "TSLA"]
portfolio = build_portfolio(tickers, "2020-01-01", "2022-01-01")
target_returns = collect(0.1:0.01:0.8)
EF_results = EfficientFrontier(portfolio, target_returns)
MC_results = MonteCarloOptimizer(portfolio)


scatter(MC_results.volatility, MC_results.returns, marker_z=MC_results.sharpe, colorbar=true, 
		colorbar_title="Sharpe Ratio", label="MonteCarlo")
plot!(EF_results.volatility, EF_results.returns, linewidth=2, 
	  linestyle=:dash, linecolor=:black, label="EffFrontier", legend=:topleft)

xlabel!("Volatility")
ylabel!("Expected Returns")
savefig("portfoliooptim_example.png")
