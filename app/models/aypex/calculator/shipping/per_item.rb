require_dependency "aypex/shipping_calculator"

module Aypex
  module Calculator::Shipping
    class PerItem < ShippingCalculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :amount, default: 0.0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        I18n.t(:shipping_flat_rate_per_item, scope: :aypex)
      end

      def compute_package(package)
        compute_from_quantity(package.contents.sum(&:quantity))
      end

      def compute_from_quantity(quantity)
        amount * quantity
      end
    end
  end
end
