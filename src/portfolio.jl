
abstract type PortfolioData end

struct Portfolio <: PortfolioData
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

function Base.show(io::IO, portfolio::Portfolio)
	println(io, "Portfolio starts on $(portfolio.start_date) and ends on $(portfolio.stop_date)")
	println(io, "Total of $(length(keys(portfolio.stocks))) stocks: $(keys(portfolio.stocks))")
end

function pct_change(input::AbstractVector)::Vector{Union{Missing, Float64}}
	change = [i == 1 ? missing : (input[i]-input[i-1])/input[i-1] for i in eachindex(input)]
	return change[2:end] # drop the missing value
end

function compute_daily_returns(data::Matrix{Float64})::Matrix{Float64}
	return hcat(pct_change.(eachcol(data))...)
end

function compute_mean_returns(data::Matrix{Float64})::Vector{Float64}
	return mean.(eachcol(data))
end

function compute_covariance_matrix(data::Matrix{Float64})
	return cov(data)
end

function build_portfolio(tickers::Array{String}, from::String, to::String; 
		                 risk_free_rate::Float64=0.05, freq::Int64=252)
	stocks = Dict(ticker => Stock(ticker, from, to) for ticker in tickers)
	stock_data = hcat([stocks[key].adjclose for key in keys(stocks)]...)
	daily_returns = compute_daily_returns(stock_data)
	mean_returns = compute_mean_returns(daily_returns)
	cov_matrix   = compute_covariance_matrix(daily_returns)
	Portfolio(stocks, stock_data, daily_returns, 
			  mean_returns, cov_matrix, risk_free_rate,
			  freq, from, to)
end


struct AnnualizedPortfolioQuantities <: PortfolioData
	expected_returns::Float64
	volatility::Float64
	sharpe::Float64
end

function AnnualizedPortfolioQuantities(weights::Vector{Float64},
								  mean_returns::Vector{Float64},
								  cov_matrix::Matrix{Float64},
								  risk_free_rate::Float64,
								  freq::Int64)
	expected_returns = (weights' *  mean_returns)*freq
	volatility       = (sqrt(weights' * (cov_matrix*weights))) *sqrt(freq)
	sharpe           = (expected_returns - risk_free_rate) / volatility
	AnnualizedPortfolioQuantities(expected_returns, volatility, sharpe)
end

function AnnualizedPortfolioQuantities(weights::Vector{Float64},
		                               portfolio::Portfolio)
	mean_returns = portfolio.mean_returns
	cov_matrix   = portfolio.cov_matrix
	freq          = portfolio.freq
	risk_free_rate = portfolio.risk_free_rate

	expected_returns = (weights' *  mean_returns)*freq
	volatility       = (sqrt(weights' * (cov_matrix*weights))) *sqrt(freq)
	sharpe           = (expected_returns - risk_free_rate) / volatility
	AnnualizedPortfolioQuantities(expected_returns, volatility, sharpe)
end
