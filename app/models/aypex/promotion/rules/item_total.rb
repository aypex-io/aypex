# A rule to apply to an order greater than (or greater than or equal to)
# a specific amount
module Aypex
  class Promotion
    module Rules
      class ItemTotal < PromotionRule
        typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
          s.decimal :amount_min, default: 100.00, null: false
          s.decimal :amount_max, default: 1000.00, null: false
          s.string :operator_min, default: ">", null: false
          s.string :operator_max, default: "<", null: false
        end

        OPERATORS_MIN = ["gt", "gte"]
        OPERATORS_MAX = ["lt", "lte"]

        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(order, _options = {})
          item_total = order.item_total

          lower_limit_condition = item_total.send((operator_min == "gte") ? :>= : :>, BigDecimal(amount_min.to_s))
          upper_limit_condition = item_total.send((operator_max == "lte") ? :<= : :<, BigDecimal(amount_max.to_s))

          eligibility_errors.add(:base, ineligible_message_max) unless upper_limit_condition
          eligibility_errors.add(:base, ineligible_message_min) unless lower_limit_condition

          eligibility_errors.empty?
        end

        private

        def formatted_amount_min
          Aypex::Money.new(amount_min).to_s
        end

        def formatted_amount_max
          Aypex::Money.new(amount_max).to_s
        end

        def ineligible_message_max
          if operator_max == "lt"
            eligibility_error_message(:item_total_more_than_or_equal, amount: formatted_amount_max)
          else
            eligibility_error_message(:item_total_more_than, amount: formatted_amount_max)
          end
        end

        def ineligible_message_min
          if operator_min == "gte"
            eligibility_error_message(:item_total_less_than, amount: formatted_amount_min)
          else
            eligibility_error_message(:item_total_less_than_or_equal, amount: formatted_amount_min)
          end
        end
      end
    end
  end
end
