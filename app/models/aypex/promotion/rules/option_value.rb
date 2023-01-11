module Aypex
  class Promotion
    module Rules
      module OptionValueWithNumerificationSupport
        def eligible_values
          values = super || {}
          values.keys.zip(
            values.values.map do |v|
              (v.is_a?(Array) ? v : v.split(","))
            end
          ).to_h
        end
      end

      class OptionValue < PromotionRule
        prepend OptionValueWithNumerificationSupport

        MATCH_POLICIES = %w[any]
        typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
          s.string :match_policy, default: "any", null: false
          s.any :eligible_values
        end

        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(promotable, _options = {})
          case match_policy
          when "any"
            promotable.line_items.any? { |item| actionable?(item) }
          end
        end

        def actionable?(line_item)
          product_id = line_item.product_id
          option_values_ids = line_item.variant.option_value_ids
          eligible_product_ids = eligible_values.keys
          eligible_value_ids = eligible_values[product_id]

          eligible_product_ids.include?(product_id) && (eligible_value_ids & option_values_ids).present?
        end
      end
    end
  end
end
