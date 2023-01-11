require_dependency "aypex/shipping_calculator"

module Aypex
  module Calculator::Shipping
    class FlatPercentItemTotal < ShippingCalculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :flat_percent, default: 0.0, null: false
      end

      def self.description
        Aypex.t(:flat_percent)
      end

      def compute_package(package)
        compute_from_price(total(package.contents))
      end

      def compute_from_price(price)
        value = price * BigDecimal(flat_percent.to_s) / 100.0
        (value * 100).round.to_f / 100
      end
    end
  end
end
