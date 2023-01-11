require_dependency "aypex/shipping_calculator"

module Aypex
  module Calculator::Shipping
    class FlexiRate < ShippingCalculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :first_item, default: 0.0, null: false
        s.decimal :additional_item, default: 0.0, null: false
        s.integer :max_items, default: 0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        Aypex.t(:shipping_flexible_rate)
      end

      def compute_package(package)
        quantity = package.contents.sum(&:quantity)

        compute_from_quantity(quantity)
      end

      delegate :compute_from_quantity, to: :flexi_rate_calculator

      private

      def flexi_rate_calculator
        ::Aypex::Calculator::Promotion::FlexiRate.new(
          additional_item: additional_item,
          first_item: first_item,
          max_items: max_items,
          currency: currency
        )
      end
    end
  end
end
