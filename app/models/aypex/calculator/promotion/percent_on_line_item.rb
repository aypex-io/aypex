module Aypex
  module Calculator::Promotion
    class PercentOnLineItem < Calculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :percent, default: 0.0, null: false
      end

      def self.description
        I18n.t(:percent_per_item, scope: :aypex)
      end

      def compute(target_item = nil, **kwargs)
        computed_amount = (target_item.amount * percent / 100).round(2)

        # We don't want to cause the promotion adjustments to push the order into a negative total.
        if computed_amount > target_item.amount
          target_item.amount
        else
          computed_amount
        end
      end
    end
  end
end
