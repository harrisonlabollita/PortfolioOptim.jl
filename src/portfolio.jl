abstract type Portfolio end

mutable struct AnnualizedPortfolio <: {Portfolio}
	mean_returns::AbstractVector
	cov_matrix::AbstractVector
	risk_free_rate::Float64
	freq::Int64
end

function AnnualizedPortfolio(df::DataFrame; 
							 risk_free_rate::Float64=0.01,
							 freq::Int64=252)

end
