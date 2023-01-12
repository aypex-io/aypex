module Aypex
  class Promotion
    module Rules
      class Category < PromotionRule
        has_many :promotion_rule_categories, class_name: "Aypex::PromotionRuleCategory",
          foreign_key: "promotion_rule_id",
          dependent: :destroy
        has_many :categories, through: :promotion_rule_categories, class_name: "Aypex::Category"

        MATCH_POLICIES = %w[any all]
        typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
          s.string :match_policy, default: "any", null: false
        end

        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(order, _options = {})
          if match_policy == "all"
            unless (categories.to_a - categories_in_order_including_parents(order)).empty?
              eligibility_errors.add(:base, eligibility_error_message(:missing_category))
            end
          else
            order_categories = categories_in_order_including_parents(order)
            unless categories.any? { |category| order_categories.include? category }
              eligibility_errors.add(:base, eligibility_error_message(:no_matching_categories))
            end
          end

          eligibility_errors.empty?
        end

        def actionable?(line_item)
          store = line_item.order.store

          store.products
            .joins(:classifications)
            .where(Aypex::Classification.table_name => {category_id: category_ids, product_id: line_item.product_id})
            .exists?
        end

        def category_ids_string
          categories.pluck(:id).join(",")
        end

        def category_ids_string=(s)
          ids = s.to_s.split(",").map(&:strip)
          self.categories = Aypex::Category.for_stores(stores).find(ids)
        end

        private

        # All categories in an order
        def order_categories(order)
          category_ids = Aypex::Classification.where(product_id: order.product_ids).pluck(:category_id).uniq

          order.store.categories.where(id: category_ids)
        end

        # ids of categories rules and categories rules children
        def categories_including_children_ids
          categories.inject([]) { |ids, category| ids += category.self_and_descendants.ids }
        end

        # categories order vs categories rules and categories rules children
        def order_categories_in_categories_and_children(order)
          order_categories(order).where(id: categories_including_children_ids)
        end

        def categories_in_order_including_parents(order)
          order_categories_in_categories_and_children(order).inject([]) { |categories, category| categories << category.self_and_ancestors }.flatten.uniq
        end
      end
    end
  end
end
