
abstract type Portfolio end

mutable struct AnnualizedPortfolio <: Portfolio
	expected_returns::Float64
	volatility::Float64
	sharpe::Float64
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
							 weights::Vector{Float64};
							 risk_free_rate::Float64=0.01,
							 freq::Int64=252)

	mean_returns = mean.(skipmissing.(daily_returns(df)))
	expected_returns = sum(weights .* mean_returns)*freq
	volatility       = sqrt(weights' * df_cor(df)*weights)*sqrt(freq)
	sharpe           = (expected_returns - risk_free_rate) / volatility

	AnnualizedPortfolio(expected_returns, volatility, sharpe)
end
