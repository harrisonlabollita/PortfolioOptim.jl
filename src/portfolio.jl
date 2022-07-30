
abstract type Portfolio end

mutable struct AnnualizedPortfolio <: Portfolio
	mean_returns::Vector{Float64}
	cov_matrix::Matrix{Float64}
	risk_free_rate::Float64
	freq::Int64
end


@inline df_mean(df::DataFrame) =  mean.(eachcol(df))
@inline df_cor(df::DataFrame) = cor(Matrix(df))

function portfolio_returns(df::DataFrame)
	data = Matrix(df)
	return data ./ lag(data) # using ShiftedArrays
end

function AnnualizedPortfolio(df::DataFrame; 
							 risk_free_rate::Float64=0.01,
							 freq::Int64=252)
	AnnualizedPortfolio(df_mean(df), df_cor(df), risk_free_rate, freq)
end
