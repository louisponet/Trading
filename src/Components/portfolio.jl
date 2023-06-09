@enumx OrderType Market Limit Stop StopLimit TrailingStop

function Base.string(t::OrderType.T)
    if t == OrderType.Market
        return "market"
    elseif t == OrderType.Limit
        return "limit"
    elseif t == OrderType.Stop
        return "stop"
    elseif t == OrderType.StopLimit
        return "stop_limit"
    elseif t == OrderType.TrailingStop
        return "trailing_stop"
    end
end

@enumx TimeInForce Day GTC OPG CLS IOC FOK
function Base.string(t::TimeInForce.T)
    if t == TimeInForce.Day
        return "Day"
    elseif t == TimeInForce.GTC
        return "gtc"
    elseif t == TimeInForce.OPG
        return "opg"
    elseif t == TimeInForce.CLS
        return "cls"
    elseif t == TimeInForce.IOC
        return "ioc"
    elseif t == TimeInForce.FOK
        return "fok"
    end
end

@component Base.@kwdef mutable struct Purchase
    ticker::String
    quantity::Float64
    type::OrderType.T
    time_in_force::TimeInForce.T

    price::Float64 = 0.0
    trail_percent::Float64 = 0.0
end

@component Base.@kwdef mutable struct Order
    ticker          ::String
    id              ::UUID
    client_order_id ::UUID
    created_at      ::Union{TimeDate, Nothing}
    updated_at      ::Union{TimeDate, Nothing}
    submitted_at    ::Union{TimeDate, Nothing}
    filled_at       ::Union{TimeDate, Nothing}
    expired_at      ::Union{TimeDate, Nothing}
    canceled_at     ::Union{TimeDate, Nothing}
    failed_at       ::Union{TimeDate, Nothing}
    filled_qty      ::Float64
    filled_avg_price::Float64
    status          ::String

    requested_quantity::Float64
end

@component Base.@kwdef mutable struct Sale
    ticker::String
    quantity::Float64
    type::OrderType.T
    time_in_force::TimeInForce.T

    price::Float64 = 0.0
    trail_percent::Float64 = 0.0
end

@component struct Filled
    avg_price::Float64
    quantity::Float64
end

# Dollars
@component mutable struct Cash
    cash::Float64
end

@component mutable struct PurchasePower
    cash::Float64
end

@component mutable struct Position
    ticker::String
    quantity::Float64
end

@component struct PortfolioSnapshot
    positions::Vector{Position}
    cash::Float64
    value::Float64
end
Base.zero(d::PortfolioSnapshot) = PortfolioSnapshot(Position[], 0.0, 0.0)
PortfolioSnapshot(v::Float64) = PortfolioSnapshot(Position[], 0.0, v)
for op in (:+, :-, :*, :/)
    @eval @inline Base.$op(b1::PortfolioSnapshot, b2::PortfolioSnapshot) = PortfolioSnapshot($op(b1.value, b2.value))
end
@inline Base.:(/)(b::PortfolioSnapshot, i::Int) = PortfolioSnapshot(b.value/i)
@inline Base.:(^)(b::PortfolioSnapshot, i::Int) = PortfolioSnapshot(b.value^i)

@inline Base.:(*)(b::PortfolioSnapshot, i::AbstractFloat) = PortfolioSnapshot(b.value*i)
@inline Base.:(*)(i::AbstractFloat, b::PortfolioSnapshot) = b * i
@inline Base.:(*)(i::Integer, b::PortfolioSnapshot) = b * i
@inline Base.sqrt(b::PortfolioSnapshot) = PortfolioSnapshot(sqrt(b.value))
@inline Base.:(<)(i::Number, b::PortfolioSnapshot) = i < b.value
@inline Base.:(<)(b::PortfolioSnapshot, i::Number) = b.value < i
@inline Base.:(>)(i::Number, b::PortfolioSnapshot) = i > b.value
@inline Base.:(>)(b::PortfolioSnapshot, i::Number) = b.value > i
@inline Base.:(>=)(i::Number, b::PortfolioSnapshot) = i >= b.value
@inline Base.:(>=)(b::PortfolioSnapshot, i::Number) = b.value >= i
@inline Base.:(<=)(i::Number, b::PortfolioSnapshot) = i <= b.value
@inline Base.:(<=)(b::PortfolioSnapshot, i::Number) = b.value <= i

@assign PortfolioSnapshot with Is{Indicator}

@component struct Strategy
    stage::Stage
    only_day::Bool
end
