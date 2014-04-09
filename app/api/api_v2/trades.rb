module APIv2
  class Trades < Grape::API

    desc 'Get recent trades on market.'
    params do
      requires :market,    type: String,  values: ::APIv2::Mount::MARKETS
      optional :limit,     type: Integer, range: 1..1000, default: 50, desc: 'Limit the number of returned trades. Default to 50.'
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only trades executed after the time will be returned."
    end
    get "/trades" do
      trades = Trade.with_currency(params[:market]).order('id desc').limit(params[:limit])
      trades = trades.where('created_at >= ?', time_from) if time_from

      present trades, with: APIv2::Entities::Trade
    end

    desc 'Get your executed trades.'
    params do
      requires :market,    type: String,  values: ::APIv2::Mount::MARKETS
      optional :limit,     type: Integer, range: 1..1000, default: 50, desc: 'Limit the number of returned trades. Default to 50.'
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only trades executed after the time will be returned."
    end
    get "/trades/my" do
      authenticate!

      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], from: time_from
      )

      present trades, with: APIv2::Entities::Trade
    end

  end
end
