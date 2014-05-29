module Matching
  class Engine

    attr :ask_orders, :bid_orders

    def initialize(market, options={})
      @market = market
      @ask_orders = OrderBook.new(:ask)
      @bid_orders = OrderBook.new(:bid)
    end

    def submit(order)
      book, counter_book = get_books order.type
      match order, counter_book
      book.add order unless order.filled?
    rescue
      Rails.logger.fatal "Failed to submit #{order}: #{$!}"
      Rails.logger.fatal $!.backtrace.join("\n")
    end

    def cancel(order)
      book, counter_book = get_books order.type
      book.remove order
    rescue
      Rails.logger.fatal "Failed to cancel #{order}: #{$!}"
      Rails.logger.fatal $!.backtrace.join("\n")
    end

    def dump
      { ask_orders: @ask_orders.dump,
        bid_orders: @bid_orders.dump }
    end

    private

    def get_books(type)
      case type
      when :ask
        [@ask_orders, @bid_orders]
      when :bid
        [@bid_orders, @ask_orders]
      end
    end

    def match(order, counter_book)
      return if order.filled?

      counter_order = counter_book.top
      return unless counter_order

      if trade = order_match?(order, counter_order)
        counter_book.fill_top trade[1]
        order.fill trade[1]

        publish order, counter_order, trade[0], trade[1]

        match order, counter_book
      end
    end

    def order_match?(order, counter_order)
      if counter_order.is_a?(LimitOrder) # limit/market match limit
        if order.crossed?(counter_order.price)
          price  = counter_order.price
          volume = [order.volume, counter_order.volume].min
          [price, volume]
        end
      elsif order.is_a?(LimitOrder) # limit match market
        price = order.price
        volume = [order.volume, counter_order.volume].min
        [price, volume]
      else # market match market
      end
    end

    def publish(order, counter_order, price, volume)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      Rails.logger.info "[#{@market.id}] new trade - #{ask} #{bid} price: #{price} volume: #{volume}"

      AMQPQueue.enqueue(
        :trade_executor,
        {market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume},
        {persistent: false}
      )
    end

  end
end
