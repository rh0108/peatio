module Deposits
  module Coinable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :payment_transaction_id
      validates_uniqueness_of :payment_transaction_id
      belongs_to :payment_transaction
    end

    def channel
      @channel ||= DepositChannel.find_by_key(self.class.name.demodulize.underscore)
    end

    def min_confirm?(confirmations)
      update_confirmations(confirmations)
      confirmations >= channel.min_confirm && confirmations < channel.max_confirm
    end

    def max_confirm?(confirmations)
      update_confirmations(confirmations)
      confirmations >= channel.max_confirm
    end

    def update_confirmations(confirmations)
      if !self.new_record? && self.memo.to_s != confirmations.to_s
        self.update_attribute(:memo, confirmations.to_s)
      end
    end

    def blockchain_url
      currency_obj.blockchain_url(txid)
    end
  end
end
