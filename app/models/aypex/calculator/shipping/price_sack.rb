require_dependency "aypex/shipping_calculator"

module Aypex
  module Calculator::Shipping
    class PriceSack < ShippingCalculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :minimal_amount, default: 0.0, null: false
        s.decimal :normal_amount, default: 0.0, null: false
        s.decimal :discount_amount, default: 0.0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        Aypex.t(:shipping_price_sack)
      end

      def compute_package(package)
        compute_from_price(total(package.contents))
      end

      def compute_from_price(price)
        if price < minimal_amount
          normal_amount
        else
          discount_amount
        end
      end
    end
  end
end
