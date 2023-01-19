module Aypex
  module Calculator::Promotion
    class FlexiRate < Calculator
      typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.decimal :first_item, default: 0.0, null: false
        s.decimal :additional_item, default: 0.0, null: false
        s.integer :max_items, default: 0, null: false
        s.string :currency, default: "USD", null: false
      end

      def self.description
        I18n.t(:flexible_rate, scope: :aypex)
      end

      def self.available?(_object)
        true
      end

      def compute(target_item = nil, **kwargs)
        compute_from_quantity(target_item.quantity)
      end

      def compute_from_quantity(quantity)
        count = [quantity, max_items].reject(&:zero?).min

        return BigDecimal("0") if count.zero?

        first_item + (count - 1) * additional_item
      end
    end
  end
end
