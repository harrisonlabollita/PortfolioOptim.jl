function neg_sharpe_ratio(weights::Vector{Float64}, 
						  mean_returns::Vector{Float64},
						  cov_matrix::Matrix{Float64},
						  risk_free_rate::Float64,
						  freq::Int64
						  )

	ann_quant = AnnualizedPortfolioQuant(weights, 
										mean_returns,
										cov_matrix;
										risk_free_rate=risk_free_rate,
										freq=freq)
	return -ann_quant.sharpe
end

function volatility(weights::Vector{Float64},
					mean_returns::Vector{Float64},
					cov_matrix::Matrix{Float64},
				    risk_free_rate::Float64,
				    freq::Int64
					)

	ann_quant = AnnualizedPortfolioQuant(weights, 
										mean_returns,
										cov_matrix;
										risk_free_rate=risk_free_rate,
										freq=freq)

	return ann_quant.volatility
end

function returns(weights::Vector, 
				 mean_returns::Vector,
				 cov_matrix::Matrix,
			     risk_free_rate::Float64,
			     freq::Int64)

	ann_quant = AnnualizedPortfolioQuant(weights, 
										mean_returns,
										cov_matrix)

	return ann_quant.expected_returns
end

function EfficientFrontier(portfolio::Portfolio,	# here we pass an annualized portfolio
						   min_function::Function)
	sco = pyimport("scipy.optimize") # TODO: switch to Optim.jl?

	mean_returns = portfolio.mean_returns
	cov_matrix   = portfolio.cov_matrix
	risk_free_rate = portfolio.risk_free_rate
	freq           = portfolio.freq

	init_weights = ones(length(mean_returns)) ./ length(mean_returns)
	bounds = Tuple((0,1) for stock=1:length(mean_returns))

	constraints = Dict("type" => "eq", "fun" => x -> sum(x) - 1)
	
	F(x) = min_function(x, mean_returns, cov_matrix, risk_free_rate, freq)
	result = sco.minimize(F,
						  x0=init_weights,
						  method="SLSQP",
						  bounds=bounds,
						  constraints=constraints)
	return result
end

		                   
