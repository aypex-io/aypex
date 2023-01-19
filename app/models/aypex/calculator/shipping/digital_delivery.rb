require_dependency "aypex/shipping_calculator"

module Aypex
  module Calculator::Shipping
    class DigitalDelivery < ShippingCalculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :amount, default: 0.0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        I18n.t("aypex.digital.digital_delivery")
      end

      def compute_package(_package = nil)
        amount
      end

      def available?(package)
        package.contents.all? { |content| content.variant.digital? }
      end
    end
  end
end
