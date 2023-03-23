@component Base.@kwdef mutable struct TimingData
    time::TimeDate = TimeDate(now())
    dtime::Period  = Minute(1)
end

@component Base.@kwdef mutable struct AccountInfo
    key_id::String
    secret_key::String
    rate::Int=200
    last::DateTime = now()
    nrequests::Int=0
end
AccountInfo(x::String, y::String; kwargs...) =
    AccountInfo(key_id=x, secret_key = y; kwargs...)
    
header(a) = ["APCA-API-KEY-ID" => a.key_id, "APCA-API-SECRET-KEY" => a.secret_key]

@component struct Trade
    exchange::String
    price::Float64
    size::Int
    conditions::Vector{String}
end

function Base.show(io::IO, t::Trade)
    println(io,"""
   time:       $(t.time)
    exchange:   $(EXCHS[t.exchange])
    price:      $(t.price)
    size:       $(t.size)
    conditions: $(t.conditions)
    """)
end

@component struct Quote
    ask_exchange::String
    ask_price::Float64
    ask_size::Int
    bid_exchange::String
    bid_price::Float64
    bid_size::Int
    conditions::Vector{String}
end

function Base.show(io::IO, t::Quote)
    println(io,"""
    ask exchange:   $(EXCHS[t.ask_exchange])
    ask price:      $(t.ask_price)
    ask size:       $(t.ask_size)
    bid exchange:   $(EXCHS[t.ask_exchange])
    bid price:      $(t.ask_price)
    bid size:       $(t.ask_size)
    conditions:     $(t.conditions)
    """)
end

@component struct Open
    v::Float64
end
@component struct Close
    v::Float64
end
@component struct High
    v::Float64
end
@component struct Low
    v::Float64
end
@component struct Volume
    v::Float64
end

@component struct LogVal{T}
    v::T
end

for T in (:Open, :Close, :High, :Low, :Volume, :LogVal)
    for op in (:+, :-, :*, :/)
        @eval @inline Base.$op(b1::$T, b2::$T) = $T($op(b1.v,   b2.v))
    end
    @eval begin
        Base.zero(::$T) = $T(0.0)
        @inline Base.:(/)(b::$T, i::Int) = $T(b.v/i)
        @inline Base.:(^)(b::$T, i::Int) = $T(b.v^i)

        @inline Base.:(*)(b::$T, i::AbstractFloat) = $T(b.v * i)
        @inline Base.:(*)(i::AbstractFloat, b::$T) = b.v * i
        @inline Base.:(*)(i::Int, b::$T) = b.v * i
        @inline Base.sqrt(b::$T) = $T(sqrt(b.v))
        @inline Base.isless(b::$T, i) = b.v < i
        @inline value(b::$T) = b.v
        @inline Base.:(<)(i::Number, b::$T) = i < b.v
        @inline Base.:(<)(b::$T, i::Number) = b.v < i
        @inline Base.:(>)(i::Number, b::$T) = i > b.v
        @inline Base.:(>)(b::$T, i::Number) = b.v > i
        @inline Base.:(>=)(i::Number, b::$T) = i >= b.v
        @inline Base.:(>=)(b::$T, i::Number) = b.v >= i
        @inline Base.:(<=)(i::Number, b::$T) = i <= b.v
        @inline Base.:(<=)(b::$T, i::Number) = b.v <= i

        @assign $T with Is{Indicator}
    end
end

@component struct TimeStamp
    t::TimeDate
end

TimeStamp() = TimeStamp(TimeDate(now()))

@pooled_component mutable struct Dataset
    ticker::String
    timeframe::String
    start::TimeDate
    stop::Union{TimeDate, Nothing}
    first_e::Entity
    last_e::Entity
end

Dataset(ticker, timeframe, start, stop=nothing) = Dataset(ticker, timeframe, start, stop, Entity(0), Entity(0))

@component struct TickerQueue
    q::SPMCQueue
end

@component struct TradeConnection
    websocket::HTTP.WebSockets.WebSocket
end

@component struct New end
