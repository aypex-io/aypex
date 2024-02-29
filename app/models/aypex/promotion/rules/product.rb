module Aypex
  class Promotion
    module Rules
      # A rule to limit a promotion based on products in the order.
      # Can require all or any of the products to be present.
      # Valid products either come from assigned product group or are assigned directly to the rule.
      class Product < PromotionRule
        has_many :product_promotion_rules, class_name: "Aypex::ProductPromotionRule",
          foreign_key: :promotion_rule_id,
          dependent: :destroy
        has_many :products, through: :product_promotion_rules, class_name: "Aypex::Product"

        MATCH_POLICIES = %w[any all none]
        typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
          s.string :match_policy, default: "any", null: false
        end

        # scope/association that is used to test eligibility
        def eligible_products
          products
        end

        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(order, _options = {})
          return true if eligible_products.empty?

          if match_policy == "all"
            unless eligible_products.all? { |p| order.products.include?(p) }
              eligibility_errors.add(:base, eligibility_error_message(:missing_product))
            end
          elsif match_policy == "any"
            unless order.products.any? { |p| eligible_products.include?(p) }
              eligibility_errors.add(:base, eligibility_error_message(:no_applicable_products))
            end
          else
            unless order.products.none? { |p| eligible_products.include?(p) }
              eligibility_errors.add(:base, eligibility_error_message(:has_excluded_product))
            end
          end

          eligibility_errors.empty?
        end

        def actionable?(line_item)
          case match_policy
          when "any", "all"
            product_ids.include? line_item.variant.product_id
          when "none"
            product_ids.exclude? line_item.variant.product_id
          else
            raise "unexpected match policy: #{match_policy.inspect}"
          end
        end

        def product_ids_string
          product_ids.join(",")
        end

        def product_ids_string=(s)
          # check this
          self.product_ids = s
        end
      end
    end
  end
end
