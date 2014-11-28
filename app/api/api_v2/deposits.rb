module APIv2
  class Deposits < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get your deposits information'
    params do
      use :auth
      optional :currency, type: String, values: Currency.all.map(&:code), desc: "Currency value contains  #{Currency.all.map(&:code).join(',')}"
    end
    get "/deposits" do
      authenticate!

      if params[:currency]
        present current_user.deposits.with_currency(params[:currency]).one_day.recent, with: APIv2::Entities::Deposit
      else
        present current_user.deposits.one_day.recent, with: APIv2::Entities::Deposit
      end
    end

    desc 'Get single deposit information'
    params do
      use :auth
      requires :tx_id
    end
    get "/deposits/:tx_id" do
      authenticate!
      present current_user.deposits.find_by(txid: params[:tx_id]), with: APIv2::Entities::Deposit
    end
  end
end
