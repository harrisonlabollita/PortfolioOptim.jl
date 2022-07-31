
abstract type PortfolioData end

mutable struct Portfolio <: PortfolioData
	stocks::Dict{String, StockData}
	stock_data::Matrix{Float64}
	daily_returns::Matrix{Union{Missing, Float64}}
	mean_returns::Vector{Float64}
	cov_matrix::Matrix{Float64}
	risk_free_rate::Float64
	freq::Int64
	start_date::String
	stop_date::String
end

function pct_change(input::AbstractVector)::Vector{Union{Missing, Float64}}
	change = [i == 1 ? missing : (input[i]-input[i-1])/input[i-1] for i in eachindex(input)]
end

function compute_daily_returns(data::Matrix{Float64})::Matrix{Union{Missing, Float64}}
	return hcat(pct_change.(eachcol(data))...)
end

function compute_mean_returns(data::Matrix{Union{Missing, Float64}})::Vector{Float64}
	return mean.(skipmissing.(eachcol(data)))
end

function compute_correlation_matrix(data::Matrix{Float64})
	return cor(data)
end

function build_portfolio(tickers::Array{String}, from::String, to::String; 
		                 risk_free_rate::Float64=0.01, freq::Int64=252,)
	stocks = Dict(ticker => Stock(ticker, from, to) for ticker in tickers)
	stock_data = hcat([stocks[key].adjclose for key in keys(stocks)]...)
	daily_returns = compute_daily_returns(stock_data)
	mean_returns = compute_mean_returns(daily_returns)
	cov_matrix   = compute_correlation_matrix(stock_data)
	Portfolio(stocks, stock_data, daily_returns, 
			  mean_returns, cov_matrix, risk_free_rate,
			  freq, from, to)
end


mutable struct AnnualizedPortfolioQuantities <: PortfolioData
	expected_returns::Float64
	volatility::Float64
	sharpe::Float64
end

function AnnualizedPortfolioQuantities(weights::Vector{Float64},
								  mean_returns::Vector{Float64},
								  cov_matrix::Matrix{Float64};
								  risk_free_rate::Float64=0.01,
								  freq::Int64=252)
	expected_returns = sum(weights .* mean_returns)*freq
	volatility       = sqrt(weights' * cov_matrix*weights)*sqrt(freq)
	sharpe           = (expected_returns - risk_free_rate) / volatility
	AnnualizedPortfolioQuantities(expected_returns, volatility, sharpe)
end
