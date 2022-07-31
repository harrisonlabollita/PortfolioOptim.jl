
abstract type Portfolio end

mutable struct AnnualizedPortfolio <: Portfolio
	mean_returns::Vector{Float64}
	cov_matrix::Matrix{Float64}
	risk_free_rate::Float64
	freq::Int64
end


@inline df_mean(df::DataFrame) =  mean.(eachcol(df))
@inline df_cor(df::DataFrame) = cor(Matrix(df))

function pct_change(input)
	[i == 1 ? missing : (input[i]-input[i-1])/input[i-1] for i in eachindex(input)]
end

function daily_returns(df::DataFrame)
	data = Matrix{Float64}(df)
	return pct_change.(eachcol(data))
end


function AnnualizedPortfolio(df::DataFrame,
							 risk_free_rate::Float64=0.01,
							 freq::Int64=252)

	mean_returns = mean.(skipmissing.(daily_returns(df)))
	cov_matrix   = df_cor(df)

	AnnualizedPortfolio(mean_returns, cov_matrix, risk_free_rate, freq)
end

mutable struct AnnualizedPortfolioQuant
	expected_returns::Float64
	volatility::Float64
	sharpe::Float64
end


function AnnualizedPortfolioQuant(weights::Vector{Float64},
								  mean_returns::Vector{Float64},
								  cov_matrix::Matrix{Float64};
								  risk_free_rate::Float64=0.01,
								  freq::Int64=252)
	expected_returns = sum(weights .* mean_returns)*freq
	volatility       = sqrt(weights' * cov_matrix*weights)*sqrt(freq)
	sharpe           = (expected_returns - risk_free_rate) / volatility

	AnnualizedPortfolioQuant(expected_returns, volatility, sharpe)
end
