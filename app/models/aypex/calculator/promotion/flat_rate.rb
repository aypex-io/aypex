module Aypex
  module Calculator::Promotion
    class FlatRate < Calculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :amount, default: 0.0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        I18n.t(:flat_rate_per_order, scope: :aypex)
      end

      def compute(target_item = nil, **kwargs)
        if target_item && currency.casecmp(target_item.currency.upcase).zero?
          amount
        else
          0
        end
      end
    end
  end
end
