module Aypex
  class Promotion
    module Rules
      class User < PromotionRule
        belongs_to :user, class_name: "::#{Aypex::Config.user_class}"

        has_many :promotion_rule_users, class_name: "Aypex::PromotionRuleUser",
          foreign_key: :promotion_rule_id,
          dependent: :destroy
        has_many :users, through: :promotion_rule_users, class_name: "::#{Aypex::Config.user_class}"

        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(order, _options = {})
          users.include?(order.user)
        end

        def user_ids_string
          user_ids.join(",")
        end

        def user_ids_string=(s)
          # check this
          self.user_ids = s
        end
      end
    end
  end
end
