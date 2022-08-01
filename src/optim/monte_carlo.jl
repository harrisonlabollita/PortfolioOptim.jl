struct MonteCarloRun <: PortfolioOptimResults
	weights::Vector{Float64}
	metrics::AnnualizedPortfolioQuantities
end

struct MonteCarloResults <: PortfolioOptimResults
	portfolio::Portfolio
	raw_results::Vector{MonteCarloRun}
	optim_sharpe_weights::Vector{Float64}
	optim_vol_weights::Vector{Float64}
end

function Base.show(io::IO, results::MonteCarloResults)
	sharpe = AnnualizedPortfolioQuantities(results.optim_sharpe_weights, results.portfolio)
	vol = AnnualizedPortfolioQuantities(results.optim_vol_weights, results.portfolio)

	println(io, "Summary of Monte Carlo Optimization results:")
	println(io, "           Optimized Sharpe Ratio: $(sharpe.sharpe)  (Vol=$(sharpe.volatility), R=$(sharpe.expected_returns))")
	println(io, "           Optimized Volatility  : $(vol.volatility) (SR=$(vol.sharpe), R=$(vol.expected_returns))")
end

function MonteCarloRun(portfolio::Portfolio, func::Function)
	num_stocks = size(portfolio.stock_data)[2]
	weights = func(num_stocks)
	weights /= sum(weights)
	@assert sum(weights) ≈ 1.0
	metrics = AnnualizedPortfolioQuantities(weights, portfolio)
	return MonteCarloRun(weights, metrics)
end


function max_sharpe(results::Vector{MonteCarloRun})::Float64
	sharpe = [x.metrics.sharpe for x in results]
	return max(sharpe)
end

function argmax_sharpe(results::Vector{MonteCarloRun})::Int64
	sharpe = [x.metrics.sharpe for x in results]
	return argmax(sharpe)
end

function min_sharpe(results::Vector{MonteCarloRun})::Float64
	sharpe = [x.metrics.sharpe for x in results]
	return min(sharpe)
end

function argmin_sharpe(results::Vector{MonteCarloRun})::Int64
	sharpe = [x.metrics.sharpe for x in results]
	return argmin(sharpe)
end

function min_vol(results::Vector{MonteCarloRun})::Float64
	vol = [x.metrics.volatility for x in results]
	return min(vol)
end

function argmin_vol(results::Vector{MonteCarloRun})::Int64
	vol = [x.metrics.volatility for x in results]
	return argmin(vol)
end

function max_vol(results::Vector{MonteCarloRun})::Float64
	vol = [x.metrics.volatility for x in results]
	return max(vol)
end

function argmax_vol(results::Vector{MonteCarloRun})::Int64
	vol = [x.metrics.volatility for x in results]
	return argmax(vol)
end

function MonteCarloOptimizer(portfolio::Portfolio; func::Function=rand, 
		            iterations::Int64=1000)

	results = Vector{MonteCarloRun}([])
	for iter=1:iterations
		push!(results, MonteCarloRun(portfolio, func))
	end

	optim_vol_idx = argmin_vol(results)
	optim_sharpe_idx = argmax_sharpe(results)
	optim_vol_weights = results[optim_vol_idx].weights
	optim_sharpe_weights = results[optim_sharpe_idx].weights
	return MonteCarloResults(portfolio, results, optim_sharpe_weights, optim_vol_weights)
end
