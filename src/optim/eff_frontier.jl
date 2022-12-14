# minimization functions
function neg_sharpe_ratio(weights::Vector{Float64}, 
						  mean_returns::Vector{Float64},
						  cov_matrix::Matrix{Float64},
						  risk_free_rate::Float64,
						  freq::Int64
						  )

	quantities = AnnualizedPortfolioQuantities(weights, 
										mean_returns,
										cov_matrix,
										risk_free_rate,
										freq)
	return -quantities.sharpe
end

function portfolio_volatility(weights::Vector{Float64},
					mean_returns::Vector{Float64},
					cov_matrix::Matrix{Float64},
				    risk_free_rate::Float64,
				    freq::Int64
					)

	quantities = AnnualizedPortfolioQuantities(weights, 
										mean_returns,
										cov_matrix,
										risk_free_rate,
										freq)

	return quantities.volatility
end

function portfolio_returns(weights::Vector, 
				 mean_returns::Vector,
				 cov_matrix::Matrix,
			     risk_free_rate::Float64,
			     freq::Int64)

	quantities = AnnualizedPortfolioQuantities(weights, 
										mean_returns,
										cov_matrix,
										risk_free_rate,
										freq)

	return quantities.expected_returns
end



# generic optimizer

function EfficientOptimizer(portfolio::Portfolio,
						   min_function::Function)

	mean_returns = portfolio.mean_returns
	cov_matrix   = portfolio.cov_matrix
	risk_free_rate = portfolio.risk_free_rate
	freq           = portfolio.freq

	init_weights = ones(length(mean_returns)) ./ length(mean_returns)
	bounds = Tuple((0,1) for stock=1:length(mean_returns))

	constraints = Dict("type" => "eq", "fun" => x -> sum(x) - 1)
	
	F(x) = min_function(x, mean_returns, cov_matrix, risk_free_rate, freq)
	result = optimize.minimize(F,
						  x0=init_weights,
						  method="SLSQP",
						  bounds=bounds,
						  constraints=constraints)
	return result
end


function EfficientReturns(portfolio::Portfolio, target::Float64)


	mean_returns = portfolio.mean_returns
	cov_matrix   = portfolio.cov_matrix
	risk_free_rate = portfolio.risk_free_rate
	freq           = portfolio.freq

	init_weights = ones(length(mean_returns)) ./ length(mean_returns)
	bounds = Tuple((0,1) for stock=1:length(mean_returns))

	F(x) = portfolio_volatility(x, mean_returns, cov_matrix, risk_free_rate, freq)
	R(x) = portfolio_returns(x, mean_returns, cov_matrix, risk_free_rate, freq)

	constraints = (Dict("type" => "eq", "fun" => x -> sum(x) - 1),
				   Dict("type" => "eq", "fun" => x -> R(x) - target) 
				   )
	
	result = optimize.minimize(F,
						  x0=init_weights,
						  method="SLSQP",
						  bounds=bounds,
						  constraints=constraints
						  )
	return result
end



struct EfficientFrontier <: PortfolioOptimResults
	portfolio::Portfolio
	returns::Vector{Float64}
	volatility::Vector{Float64}
	sharpe_ratio::Vector{Float64}
	weights::Vector{Vector{Float64}}
end

function Base.show(io::IO, results::EfficientFrontier)
	println(io, "Summary of EfficientFrontier Results:")
	println(io, "Explored $(length(results.returns)) returns")
	max_sharpe = argmax(results.sharpe_ratio)
	min_vol = argmin(results.volatility)
	println(io, "Maximum Sharpe Ratio: $(results.sharpe_ratio[max_sharpe])")
	println(io, "              Return: $(results.returns[max_sharpe])")
	println(io, "          Volatility: $(results.volatility[max_sharpe])")
	println(io, " Mininmum Volatility: $(results.volatility[min_vol])")
	println(io, "              Return: $(results.returns[min_vol])")
	println(io, "        Sharpe Ratio: $(results.sharpe_ratio[min_vol])")
end


function EfficientFrontier(portfolio::Portfolio, targets::Vector{Float64})
	eff_frontier = Dict("returns" => targets, "volatility" => [], 
						"sharpe" => [], "weights" => [])
	for target in targets
		weights = EfficientReturns(portfolio, target)["x"]

		quantities = AnnualizedPortfolioQuantities(weights, portfolio.mean_returns,
												   portfolio.cov_matrix, portfolio.risk_free_rate,
												   portfolio.freq)

		push!(eff_frontier["volatility"], quantities.volatility)
		push!(eff_frontier["sharpe"], quantities.sharpe)
		push!(eff_frontier["weights"], weights)
	end
	return EfficientFrontier(portfolio, eff_frontier["returns"], eff_frontier["volatility"],
							eff_frontier["sharpe"], eff_frontier["weights"])
end


function plot_eff(results::EfficientFrontier; kwargs...)
	vol = results.volatility
	ret = results.returns
	p = plot(vol, ret; kwargs...) 
	return p
end

function plot_eff!(results::EfficientFrontier; kwargs...)
	vol = results.volatility
	ret = results.returns
	plot!(vol, ret; kwargs...) 
end
