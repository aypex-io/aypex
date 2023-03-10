module Aypex
  module UserPaymentSource
    extend ActiveSupport::Concern

    included do
      has_many :credit_cards, class_name: "Aypex::CreditCard", foreign_key: :user_id
      def default_credit_card
        credit_cards.default.first
      end

      def payment_sources
        credit_cards.with_payment_profile.not_expired.where(payment_method: Aypex::PaymentMethod.active).not_removed
      end

      def drop_payment_source(source)
        gateway = source.payment_method
        gateway.disable_customer_profile(source)
      end
    end
  end
end
